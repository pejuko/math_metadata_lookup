# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

module MathMetadata

  class << self

    def format_author( author, format )
      result = ""
      case format
      when :text
        result += %~Id: #{author[:id]}\nPreferred: #{author[:preferred]}~
      when :html
        result += %~
  <div class="author">
      <div class="author_id">Id: #{::CGI.escapeHTML(author[:id])}</div>
      <div class="preferred">Preferred: #{::CGI.escapeHTML(author[:preferred])}</div>~
      end

      author[:forms].each do |form|
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

      result
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
MSC: #{metadata[:msc].join("; ")}
Pages: #{metadata[:range]}
ISSN: #{metadata[:issn].join('; ')}
Keywords: #{metadata[:keywords].join('; ')}
~
      when :html
        result += %~
    <div class="article">
        Id: <span class="journal">#{::CGI.escapeHTML metadata[:id].to_s}</span><br />
        Journal/Proceeding: <span class="journal">#{::CGI.escapeHTML metadata[:proceeding].to_s}</span><br />
        Title: <span class="title">#{::CGI.escapeHTML metadata[:title].to_s}</span><br />
        Authors: <span class="authors">#{::CGI.escapeHTML metadata[:authors].to_a.join("; ")}</span><br />
        Year: <span class="year">#{::CGI.escapeHTML metadata[:year].to_s}</span><br />
        Language: <span class="lang">#{::CGI.escapeHTML metadata[:language].to_s}</span><br />
        MSC: <span class="msc">#{::CGI.escapeHTML metadata[:msc].to_a.join("; ")}</span><br />
        Pages: <span class="pages">#{::CGI.escapeHTML metadata[:range].to_s}</span><br />
        ISSN: <span class="issn">#{::CGI.escapeHTML metadata[:issn].to_a.join('; ')}</span><br />
        Keywords: <span class="keywords">#{::CGI.escapeHTML metadata[:keywords].to_a.join('; ')}</span><br />
    </div>
~
      end

      result
    end

  end

end
