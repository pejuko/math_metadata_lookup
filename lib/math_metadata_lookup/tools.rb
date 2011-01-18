# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

module MathMetadata

  class << self

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

  end

end
