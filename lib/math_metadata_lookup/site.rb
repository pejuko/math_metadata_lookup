# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

require 'htmlentities'
require 'open-uri'
require 'cgi'


module MathMetadata

  SITES = []

  # Abstract class. Inherit in your sites definition.
  class Site

    def initialize( opts={} )
      @options = { :verbose => true }.merge(opts)
    end

    # register new site class
    def self.inherited( site )
      SITES << site
    end


    # search for authors
    def author( args={} )
      opts = {:name => nil}.merge(args)
      anf = author_name_forms opts[:name]

      authors = []
      anf.each do |af|
        entry = Author.new({:id => af[1], :preferred => af[0], :forms => af[2]})
        authors << entry unless entry[:id].to_s.strip.empty?
      end

      authors
    end


    # search for articles
    def article( args={} )
      opts = {:id => nil, :title => "", :year => "", :authors => [], :references => true}.merge(args)

      page = fetch_article(opts)
      articles = []
  
      return articles unless page

      if list_of_articles?(page)
        articles = get_article_list(page)
      else
        a = get_article(page, opts)
        articles << a unless a[:title].to_s.strip.empty?
      end
  
      #return [] if articles.size == 0
      articles
    end

    def to_json
      ""
    end

  protected


    def method_missing(meth, *args)
      page = args.first

      case meth.to_s
      when /^list_of_(.*)\?$/
        re = eval("self.class::LIST_OF_#{$1.upcase}_RE")
        return page =~ re
      when /^get_(.*)_m$/
        re = eval("self.class::#{$1.upcase}_RE")
        re_s = eval("self.class::#{$1.upcase}S_RE")
        m, n = args[1,2]
        m ||= 1
        n ||= 1
        res = []
        page.scan(re_s) do |match|
          entry = []
          m.times {|i| entry << match[i].to_s.strip}
          entry << []
          match[m].scan(re) do |form|
            n.times {|i| entry[m] << form[i]}
          end if match[m]
          res << entry
        end 
        return res

      when /^get_(.*)_s$/
        res = []
        what = $1
        re = eval("self.class::#{what.upcase}_RE")
        re_s = eval("self.class::#{what.upcase}S_RE")
        page =~ re_s
        entries = $1
        entries.to_s.strip.scan(re) do |match|
          res << match[0].to_s.strip
        end
        return res

      when /^get_(.*)$/
        match = eval("self.class::#{$1.upcase}_RE").match(page).to_a.map{|x| x.to_s.strip}
        match.shift
        return match.first if args[1].to_i <= 1
        return match
      end
    end
  

    # search for author name forms
    def author_name_forms( name )
      forms = []

      return forms if self.class::AUTHOR_URL.empty?
      page = fetch_author name
      forms = get_author_m page, 2, 1

      forms
    end


    def get_article_references( page )
      references = []

      refs = get_article_reference_s page

      i = 0;
      refs.each do |r|
        i+=1
        ref = Reference.new r.gsub(/<.*?>/,'').gsub(/  +/,' ').strip, i
        references << ref
      end
      
      references
    end


    def get_article_msc( page )
      mscs = get_article_msc_s page
      mscs = MathMetadata.normalize_mscs(mscs)
      mscs
    end


    def get_article( page, opts={} )
      a = Article.new( {
        :id => get_article_id(page),
        :language => get_article_language(page),
        :authors => get_article_author_s(page),
        :msc => get_article_msc(page),
        :publication => get_article_publication(page),
        :publisher => get_article_publisher(page),
        :range => MathMetadata.normalize_range(get_article_range(page)),
        :year => get_article_year(page),
        :keywords => get_article_keyword_s(page),
        :issn => get_article_issn_s(page)
      } )

      a.title = get_article_title(page)
      a.title = a.title.to_s.gsub(/<\/span>/,'')
      a.references = get_article_references(page) if opts[:references]

      a
    end


    def get_article_list( page )
      articles = []
      page.scan(self.class::ARTICLE_ENTRY_RE).each do |match|
        a = article(:id => match[0]).first
        next unless a
        articles << a unless a[:title].to_s.strip.empty?
      end
      articles
    end


    # select first n words from string which are longer then 2 characters
    def nwords(s)
      n = @options[:nwords].to_i
      words = 0
      s.split(" ").inject("") do |res,word|
        if words < n
          res << " " << word
          words += 1 if word.size > 2
        end
        res.strip
      end
    end


    def normalize_page(page, args={})
      opts = {:entities => true}.merge(args)

      if page =~ %r{<meta.*charset=([^"\s]+)}i
        if page.respond_to?(:force_encoding)
          page.force_encoding($1)
          page.encode!("utf-8")
        else
          page = Iconv.new('utf-8', $1).iconv(page)
        end
      end
      if page and opts[:entities]
        coder = HTMLEntities.new
        page = coder.decode(page)
      end

      page
    end


    def fetch_page( url, args={} )
      puts "fetching #{url}" if @options[:verbose]
      page = URI.parse(url).read
      page = normalize_page page, args
    
      page
    end
  
  
    def fetch_author( name )
      nn = MathMetadata.normalize_name(name)
      url = self.class::AUTHOR_URL % URI.escape(nn)

      fetch_page(url)
    end
  

    def join_article_authors( authors )
      authors.collect { |author| URI.escape MathMetadata.normalize_name(author) }.join(';%20') || ''
    end

    def build_article_url(title, author, year)
      self.class::ARTICLE_URL % [URI.escape(title), author, year]
    end
  
    def fetch_article( args={} )
      opts = {:id => nil, :title => "", :year => "", :authors => []}.merge(args)
      url = self.class::ARTICLE_ID_URL % URI.escape(opts[:id].to_s.strip)
      if opts[:id].to_s.strip.empty?
        author = join_article_authors opts[:authors]
        title = opts[:title]
        title = '' if not title.kind_of?(String)
        title = MathMetadata.normalize_text(title)
        title = nwords(title) if @options[:nwords]
        url = build_article_url title, author, opts[:year].to_s
      end
  
      fetch_page(url, opts)
    end

  end # Site

end # Module
