require 'rubygems'
require 'htmlentities'
require 'open-uri'
require 'i18n'


module MathMetadata

  SITES = []

  class Lookup
    attr_accessor :options

    # :sites can be :all or array of allowed sites ([:mrev, :zbl])
    def initialize( opts={} )
      @options = { :sites => :all, :verbose => true }.merge(opts)
      @sites = []
    end

    def method_missing(meth, *args)
      result = []

      sites = SITES.dup
      if (@options[:sites] != :all) or @options[:sites].kind_of?(Array)
        allowed = [@options[:sites]].flatten
        sites.delete_if{|s| not allowed.include?(s::CODE) }
      end

      sites.each do |klass|
        site = klass.new

        entry = {:site => klass::CODE, :name => klass::NAME, :url => klass::URL}
        entry[:result] = site.send(meth, *args)

        result << entry
      end

      result
    end
  end


  # Abstract class
  class Site 

    def initialize( opts={} )
      @options = { :verbose => true }.merge(opts)
    end

    def self.inherited( site )
      SITES << site
    end

    def normalize_name( name )
      trans = I18n.transliterate( name.to_s )
  
      # vyresim: Surname, N.M. => Surname, N. M.
      # mrev to jinak nenajde
      trans.gsub( /([^\s,])?\.([^\s,])/, '\1. \2' )
    end
  
  
    def author_name_forms( name )
      forms = []
      page = fetch_author(name)
  
      if page
        person = []
    
        page.scan(self.class::AUTHORS_RE) do |match|
          person = [match[0], []]
          match[1].scan(self.class::AUTHOR_RE) do |form|
            person[1] << form[0]
          end if match[1]
        end 
    
        forms << person if person.size > 0
      end
    
      forms
    end
  
  
    def article( id, title="", authors=[])
      metadata = {}
      page = fetch_article(id, title, authors)
  
      return metadata unless page
  
      page =~ self.class::ARTICLE_ID_RE
      metadata[:id] = $1.to_s.strip
      
      page =~ self.class::ARTICLE_TITLE_RE
      metadata[:title] = $1.to_s.strip
      metadata[:language] = $2.to_s.strip
      
      metadata[:authors] = []
      page =~ self.class::ARTICLE_AUTHORS_RE
      $1.to_s.strip.scan(self.class::ARTICLE_AUTHOR_RE) do |match|
        metadata[:authors] << match[0].to_s.strip
      end
      
      mscs = []
      page =~ self.class::ARTICLE_MSCS_RE
      $1.to_s.strip.scan(self.class::ARTICLE_MSC_RE) do |match|
        # $1 -- code; $2 -- description
        mscs << $1.to_s.strip
      end
      metadata[:msc] = mscs

      
      page =~ self.class::ARTICLE_PROCEEDING_RE
      metadata[:proceeding] = $1.to_s.strip
      
      page =~ self.class::ARTICLE_RANGE_RE
      metadata[:range] = $1.to_s.strip
      metadata[:year] = $2.to_s.strip
  
      return nil if metadata[:title].empty?
      metadata
    end
  
  
  protected
  
    def nwords(s)
      s.split(" ")[0...@options[:nwords].to_i].join(" ")
    end
  
  
    def fetch_page( url )
  
      puts "fetching #{url}" if @options[:verbose]
      page = URI.parse(url).read
      page = HTMLEntities.decode_entities(page) if page
    
      page
    end
  
  
    def fetch_author( name )
      nn = normalize_name(name)
      url = self.class::AUTHOR_URL % URI.escape(nn)
  
      fetch_page(url)
    end
  
  
    def fetch_article(id, title="", authors=[])
      url = self.class::ARTICLE_ID_URL % id.to_s.strip
      if id.to_s.strip.empty?
        author = authors.collect { |author| normalize_name(author) }.join('; ') || ''
        title = '' if not title.kind_of?(String)
        title = nwords(title) if @options[:nwords]
        url = self.class::ARTICLE_URL % [URI.escape(title), URI.escape(author)]
      end
  
      fetch_page(url)
    end

  end # Lookup


  # Mathematical Reviews
  # http://www.ams.org/mr-database
  class MRev < Site
    CODE = :mrev
    NAME = "Mathematical Reviews"
    URL = "http://www.ams.org/mr-database"

    AUTHORS_RE = /<h1 class="profileHead">(.*)<\/h1>(?:.*?<ul class="variations">(.*?)<\/ul>)?/m
    AUTHOR_RE = /<li>(.*)<\/li>/
    
    AUTHOR_URL = %~http://www.ams.org/mathscinet/search/authors.html?authorName=%s&Submit=Search~
    
    
    ARTICLE_ID_RE = %r{<strong>(.*?)</strong>}mi
    ARTICLE_TITLE_RE = %r{<span class="title">(.*?)</span>}mi
    ARTICLE_AUTHORS_RE = %r{<br />(<a href="/mathscinet/search/publications.html[^"]*">.*?</a>)<br />}mi
    ARTICLE_AUTHOR_RE = %r{<a href="/mathscinet/search/publications.html[^"]*">(.*?)</a>}mi
    ARTICLE_MSCS_RE = %r{<a href="/mathscinet/search/mscdoc.html\?code=[^"]*">(.*?)</a>}mi
    ARTICLE_MSC_RE = %r{\s+}mi
    ARTICLE_PROCEEDING_RE = %r{<em> (.*?) </em>}mi
    ARTICLE_RANGE_RE = %r{(\S+--\S+)}
    
    ARTICLE_ID_URL = "http://www.ams.org/msnmain?preferred_language=en&pg3=MR&s3=%s&l=20&reference_lists=show&simple_headlines=full&contributed_items=show&redirect=Providence%%2C+RI+USA&Submit=Start+Search&fn=130&form=basicsearch"
    ARTICLE_URL = "http://www.ams.org/mathscinet/search/publdoc.html?arg3=&co4=AND&co5=AND&co6=AND&co7=AND&dr=all&pg4=TI&pg5=AUCN&pg6=PC&pg7=ALLF&pg8=ET&r=1&s4=%s&s5=%s&s6=&s7=&s8=All&yearRangeFirst=&yearRangeSecond=&yrop=eq"
    
    #re = /<a href=".\/publications.html.*?onmouseover[^>]*>(.*?)(?:<sup>.*?<\/sup>)?<\/a>(?:.*?<ul>(.*?)<\/ul>)?/m
    #re-pref = /<h1 class="profileHead">(.*)<\/h1>/m
    #re = /<ul class="variations">(.*?)<\/ul>/m
    
  end # MRev



  # Zentralblatt
  # http://www.zentralblatt-math.org/zmath/
  class ZBL < Site
    CODE = :zbl
    NAME = "Zentralblatt"
    URL = "http://www.zentralblatt-math.org/zmath/"

    
    AUTHOR_URL ="http://www.zentralblatt-math.org/zbmath/authors/?q=%s"

=begin
<div class="name">
  <strong>Rákos, Attila</strong>
</div>
<div class="clear"></div>
<div class="table">
  <div class="title">Author-Id:</div>
  rakos.attila
</div>
<div class="table">

  <div class="title">Spellings:</div>
  Rákos, A. [5]; Rákos, Attila [2]
</div>
=end

    AUTHORS_RE = %r{<div class="name">\s*<strong>(.*?)</strong>.*?<div class="table">\s*<div class="title">Spellings:</div>\s*(.*?)\s*</div>}mi
    AUTHOR_RE = %r{(.*?)\s*\[\d+\](?:;\s*)?}
    
    
    ARTICLE_ID_URL = "http://www.zentralblatt-math.org/zmath/en/search?q=an:%s"
    ARTICLE_URL = "http://www.zentralblatt-math.org/zmath/en/search?q=ti:%s&au:%s"

    ARTICLE_ID_RE = %r{<a href="\?q=an:.*?complete">(.*?)</a>}mi
    ARTICLE_TITLE_RE = %r{</a><br>(.*?)\.</b>\s*\((.*?)\)<br>}mi
    ARTICLE_AUTHORS_RE = %r{<br><b>(<a href="\?q=[^"]*">.*?</a>)<br>}mi
    ARTICLE_AUTHOR_RE = %r{<a href="\?q=[^"]*">(.*?)</a>}mi
    ARTICLE_MSCS_RE = %r{<dd>(.*?)</dd>}mi
    ARTICLE_MSC_RE = %r{<a href=".*?">(.*?)</a>}mi
    ARTICLE_PROCEEDING_RE =
    ARTICLE_RANGE_RE = %r{<br>.*?, (\S+-\S+) \((.*?)\). <br>}mi

=begin
      #page_zbl =~ %r{<a href="\?q=an:.*?complete">(.*?)</a>.*?<br><b>(<a href="\?q=ai:[^"]*">.*?</a>)<br>(.*?)\.</b>\s*\((.*?)\)<br>.*?<a href="../journals/search/\?an=[^"]*">(.*?)</a> ([^,]*), ([^ ]*) \((.*?)\). <br>}mi
=end
  end # ZBL

end # module
