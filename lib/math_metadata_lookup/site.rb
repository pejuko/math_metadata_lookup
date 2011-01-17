# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

require 'htmlentities'
require 'open-uri'
require 'i18n'

module MathMetadata

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
  
  
    def author_name_forms( name, format=:ruby )
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
    
      if format != :ruby
        result = ""
        forms.each do |person|
          case format
          when :text
            result += %~Preferred: #{person[0]}~
          end
          person[1].each do |form|
            case format
            when :text
              result += %~
Other: #{form}~
            end
          end
        end

        return result
      end

      forms
    end
  
  
    def article( id, title="", authors=[], format=:ruby )
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

      page =~ self.class::ARTICLE_YEAR_RE
      metadata[:year] = $1.to_s.strip
  
      return nil if metadata[:title].empty?

      if format != :ruby
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
~
        end

        return result
      end

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

  end # Site

end # Module
