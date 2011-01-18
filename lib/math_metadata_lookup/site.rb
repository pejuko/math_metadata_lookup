# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

require 'htmlentities'
require 'open-uri'
require 'i18n'
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


    # search for author name forms
    def author_name_forms( args={} )
      opts = {:name => nil, :format => :ruby}.merge(args)
      forms = []

      page = fetch_author(opts[:name])
      forms = get_author_m page, 2, 1

      return forms if opts[:format] == :ruby

      MathMetadata.format_author(forms, opts[:format])    
    end


    # search for articles
    def article( args={} )
      opts = {:id => nil, :title => "", :authors => [], :format => :ruby}.merge(args)

      page = fetch_article(opts)
      articles = []
  
      return metadata unless page

      if list_of_articles?(page)
        articles = get_article_list page
      else
        articles << get_article(page)
      end
  
      return nil if articles.size == 0
      return articles if opts[:format] == :ruby

      articles.map{|a| MathMetadata.format_article a, opts[:format]}.join
    end


  protected


    def method_missing(meth, *args)
      page = args.first

      case meth
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
        re = eval("self.class::#{$1.upcase}_RE")
        re_s = eval("self.class::#{$1.upcase}S_RE")
        page =~ re_s
        $1.to_s.strip.scan(re) do |match|
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
  

    def get_article_references( page )
      references = get_article_reference_m page, 0, 6

      # 1=authors, 2=journal, 3=volume/issue, 4=year, 5=range, 6=ref
      i = 0;
      references.map! {|r| i+=1; {
        :number => i,
        :authors => r[0].shift.to_s.gsub(/<.*?>/,'').strip,
        :title => r[0].shift.to_s.gsub(/  +/, ' ').strip,
        :issue => r[0].shift,
        :year => r[0].shift,
        :range => r[0].shift,
        :ref => r[0].shift,
      }}

      references
    end

    
    def get_article( page )
      metadata = {}
      metadata[:id] = get_article_id page
      metadata[:title], metadata[:language] = get_article_title page, 2
      metadata[:authors] = get_article_author_s page
      metadata[:msc] = get_article_msc_s page
      metadata[:proceeding] = get_article_proceeding page
      metadata[:range] = get_article_range page
      metadata[:year] = get_article_year page
      metadata[:keywords] = get_article_keyword_s page
      metadata[:issn] = get_article_issn_s page
      #metadata[:references] = get_article_references page
      metadata
    end


    def get_article_list( page )
      articles = []
      page.scan(self.class::ARTICLE_ENTRY_RE) do |match|
        articles << article(:id => match[0]).first
      end
      articles
    end


    def normalize_name( name )
      trans = I18n.transliterate( name.to_s )
  
      # vyresim: Surname, N.M. => Surname, N. M.
      # mrev to jinak nenajde
      trans.gsub( /([^\s,])?\.([^\s,])/, '\1. \2' )
    end
  

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
  

    def join_article_authors( authors )
      authors.collect { |author| URI.escape normalize_name(author) }.join('; ') || ''
    end
  
    def fetch_article( args={} )
      opts = {:id => nil, :title => "", :authors => []}.merge(args)
      url = self.class::ARTICLE_ID_URL % opts[:id].to_s.strip
      if opts[:id].to_s.strip.empty?
        author = join_article_authors opts[:authors]
        title = opts[:title]
        title = '' if not title.kind_of?(String)
        title = nwords(title) if @options[:nwords]
        url = self.class::ARTICLE_URL % [URI.escape(title), author]
      end
  
      fetch_page(url)
    end

  end # Site

end # Module
