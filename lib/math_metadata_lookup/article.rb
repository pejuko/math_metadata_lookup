module MathMetadata

  class Article < Entity

    def to_text
      result = ""
      result += %~Id: #{@metadata[:id]}
Publication: #{@metadata[:publication]}
Title: #{@metadata[:title]}
Authors: #{[@metadata[:authors]].flatten.join("; ")}
Year: #{@metadata[:year]}
Language: #{@metadata[:language]}
MSC: #{@metadata[:msc].join("; ")}
Pages: #{@metadata[:range]}
ISSN: #{@metadata[:issn].join('; ')}
Keywords: #{@metadata[:keywords].join('; ')}~
      @metadata[:references].to_a.each_with_index do |ref, idx|
        result += %~
Ref.: #{idx+1}. #{[ref[:authors]].flatten.join("; ")}: #{ref[:title]}~
      end
      result += "\n\n"
      result
    end


    def to_html
      result = %~
    <div class="article">
        Id: <span class="journal">#{::CGI.escapeHTML @metadata[:id].to_s}</span><br />
        Publication: <span class="journal">#{::CGI.escapeHTML @metadata[:publication].to_s}</span><br />
        Title: <span class="title">#{::CGI.escapeHTML @metadata[:title].to_s}</span><br />
        Authors: <span class="authors">#{::CGI.escapeHTML @metadata[:authors].to_a.join("; ")}</span><br />
        Year: <span class="year">#{::CGI.escapeHTML @metadata[:year].to_s}</span><br />
        Language: <span class="lang">#{::CGI.escapeHTML @metadata[:language].to_s}</span><br />
        MSC: <span class="msc">#{::CGI.escapeHTML @metadata[:msc].to_a.join("; ")}</span><br />
        Pages: <span class="pages">#{::CGI.escapeHTML @metadata[:range].to_s}</span><br />
        ISSN: <span class="issn">#{::CGI.escapeHTML @metadata[:issn].to_a.join('; ')}</span><br />
        Keywords: <span class="keywords">#{::CGI.escapeHTML @metadata[:keywords].to_a.join('; ')}</span><br />
        References:
        <div id="ref#{@metadata[:id]}" class="references">
~
      @metadata[:references].to_a.each_with_index do |ref, idx|
        result += %~
            <div class="reference">
                Number: #{ref[:number] || idx+1}
                Authors: #{[ref[:authors]].flatten.join("; ")}
                Title: #{ref[:title]}
                Publication: #{ref[:publication]}
                Publisher: #{ref[:publisher]}
                Year: #{ref[:year]}
                Id: #{ref[:id]}
            </div>
~
      end
      result += %~
        </div>
    </div>
~
      result
    end

  end # class

end # module
