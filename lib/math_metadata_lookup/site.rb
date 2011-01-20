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
  
      return metadata unless page

      if list_of_articles?(page)
        articles = get_article_list(page)
      else
        articles << get_article(page, opts)
      end
  
      return nil if articles.size == 0
      articles
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
  

    # search for author name forms
    def author_name_forms( name )
      forms = []

      page = fetch_author name
      forms = get_author_m page, 2, 1

      forms
    end


    def get_article_references( page )
      references = []

      i = 0;
      page.scan(self.class::ARTICLE_REFERENCES_RE) do |match|
        i+=1
        entry = {:number => i, :string => match[0].gsub(/<.*?>/,'').gsub(/  +/,' ').strip}

        # 1=authors, 2=title, 3=publication, 4=year, 5=range, 6=id, 7=place, 8=publisher
        found = []
        (1..10).each do |j|
          re = eval("self.class::ARTICLE_REFERENCE_#{j}_RE")
          if entry[:string] =~ re
            case j
            when 1
              # 1=authors, 2=title, 3=publication, 4=year, 5=range, 6=id
              found = [$1, $2, $3, $4, $5, $6]
            when 2
              # 1=authors, 2=title, 3=publication, 4=range, 5=publisher, 6=place, 7=year, 8=id
              found = [$1, $2, $3, $7, $4, $8, $6, $5]
            when 3
              # 1=authors, 2=title, 3=range, 4=publication, 5=place, 6=year
              found = [$1, $2, $4, $6, $3, nil, $5]
            when 4
              # 1=authors, 2=title, 3=publication, 4=publisher, 5=place, 6=year, 7=id
              found = [$1, $2, $3, $6, nil, $7, $5, $4]
            when 5
              # 1=authors, 2=title, 3=publisher, 4=place, 5=year, 6=id
              found = [$1, $2, nil, $5, nil, $6, $4, $3]
            when 6
              # 1=authors, 2=title, 3=publisher, 4=place, 5=year, 6=id
              found = [$1, $2, nil, $5, nil, $6, $4, $3]
            when 7
              # 1=authors, 2=title, 3=publication, 4=year, 5=range, 6=id
              found = [$1, $2, $3, $4, $5, $6]
            when 8
              # 1=authors, 2=title, 3=publication, 4=year, 5=range, 6=id
              found = [$1, $2, $3, $4, $5, $6]
            when 9
              # 1=authors, 2=title, 3=publisher, 4=place
              found = [$1, $2, nil, nil, nil, nil, $4, $3]
            when 10
              # 1=authors, 2=title, 3=publication, 4=id
              found = [$1, $2, $3, nil, nil, $4, nil, nil]
            end
            found.unshift(j)
            break
          end
        end

        [:reg, :authors, :title, :publication, :year, :range, :id, :place, :publisher].each_with_index do |key, idx|
          entry[key] = found[idx]
        end

        references << entry
      end

      references
    end


    def get_article_msc( page )
      mscs = get_article_msc_s page
      mscs = mscs.map{|m| m.split(/,|;/) }.flatten.map{|m| m =~ /\s*\(?([^\s\)\(]+)\)?\s*/; $1}
      mscs
    end

    
    def get_article( page, opts={} )
      a = Article.new( {
        :id => get_article_id(page),
        :authors => get_article_author_s(page),
        :msc => get_article_msc(page),
        :publication => get_article_publication(page),
        :range => get_article_range(page),
        :year => get_article_year(page),
        :keywords => get_article_keyword_s(page),
        :issn => get_article_issn_s(page)
      } )

      a.title, a.language = get_article_title(page, 2)
      a.references = get_article_references(page) if opts[:references]

      a
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
      opts = {:id => nil, :title => "", :year => "", :authors => []}.merge(args)
      url = self.class::ARTICLE_ID_URL % opts[:id].to_s.strip
      if opts[:id].to_s.strip.empty?
        author = join_article_authors opts[:authors]
        title = opts[:title]
        title = '' if not title.kind_of?(String)
        title = nwords(title) if @options[:nwords]
        url = self.class::ARTICLE_URL % [URI.escape(title), author, opts[:year].to_s]
      end
  
      fetch_page(url)
    end

  end # Site

end # Module
