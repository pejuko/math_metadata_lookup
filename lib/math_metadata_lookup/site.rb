# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

require 'htmlentities'
require 'open-uri'
require 'i18n'
require 'cgi'


module MathMetadata

  SITES = []

  # Abstract class
  class Site 

    def initialize( opts={} )
      @options = { :verbose => true }.merge(opts)
    end

    def self.inherited( site )
      SITES << site
    end


    def method_missing(meth, *args)
      page = args.first

      case meth
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
  

    def author_name_forms( name, format=:ruby )
      forms = []

      page = fetch_author(name)
      forms = get_author_m page, 2, 1

      return forms if format == :ruby
      return format_author(forms, format)    
    end
  

    def article( id, title="", authors=[], format=:ruby )
      metadata = {}
      page = fetch_article(id, title, authors)
  
      return metadata unless page
  
      metadata[:id] = get_article_id page
      metadata[:title], metadata[:language] = get_article_title page, 2
      metadata[:authors] = get_article_author_s page
      metadata[:msc] = get_article_msc_s page
      metadata[:proceeding] = get_article_proceeding page
      metadata[:range] = get_article_range page
      metadata[:year] = get_article_year page
      metadata[:keywords] = get_article_keyword_s page
      metadata[:issn] = get_article_issn_s page
  
      return nil if metadata[:title].empty?
      return metadata if format == :ruby

      format_article metadata, format
    end


    def format_author( forms, format )
      result = ""
      forms.each do |person|
        case format
        when :text
          result += %~Id: #{person[1]}\nPreferred: #{person[0]}~
        when :html
          result += %~
  <div class="author">
      <div class="author_id">Id: #{::CGI.escapeHTML(person[1])}</div>
      <div class="preferred">Preferred: #{::CGI.escapeHTML(person[0])}</div>~
        end

        person[2].each do |form|
          case format
          when :text
            result += %~
Other: #{form}~
          when :html
            result += %~
      <div class="other">Other: #{::CGI.escapeHTML(form)}</div>~
          end
        end

        case format
        when :html
          result += %~
  </div>
~
        end
      end

      return result
    end
  

    def format_article( metadata, format )
      result = ""
      case format
      when :text
        result += %~Id: #{metadata[:id]}
Journal/Proceeding: #{metadata[:proceeding]}
Title: #{metadata[:title]}
Authors: #{metadata[:authors].join("; ")}
Year: #{metadata[:year]}
Language: #{metadata[:language]}
MSC: #{metadata[:msc].join(", ")}
Pages: #{metadata[:range]}
ISSN: #{metadata[:issn].join('; ')}
Keywords: #{metadata[:keywords].join('; ')}
~
      when :html
        result += %~
    <div class="article">
        Journal/Proceeding: <span class="journal">#{::CGI.escapeHTML metadata[:proceeding]}</span><br />
        Title: <span class="title">#{::CGI.escapeHTML metadata[:title]}</span><br />
        Authors: <span class="authors">#{::CGI.escapeHTML metadata[:authors].join("; ")}</span><br />
        Year: <span class="year">#{::CGI.escapeHTML metadata[:year]}</span><br />
        Language: <span class="lang">#{::CGI.escapeHTML metadata[:language]}</span><br />
        MSC: <span class="msc">#{::CGI.escapeHTML metadata[:msc].join(", ")}</span><br />
        Pages: <span class="pages">#{::CGI.escapeHTML metadata[:range]}</span><br />
        ISSN: <span class="issn">#{::CGI.escapeHTML metadata[:issn].join('; ')}</span><br />
        Keywords: <span class="keywords">#{::CGI.escapeHTML metadata[:keywords].join('; ')}</span><br />
    </div>
~
      end

      result
    end

  protected

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

  end # Site

end # Module
