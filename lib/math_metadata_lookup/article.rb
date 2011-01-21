module MathMetadata

  class Article < Entity

    def ==(article)
      similarity(article) > 0.9
    end


    def similarity(article)
      td = MathMetadata.levenshtein_distance @metadata[:title].to_s, article[:title].to_s
      ad = MathMetadata.levenshtein_distance [@metadata[:authors]].flatten.sort.join(";"), [article[:authors]].flatten.sort.join(";")
      yd = MathMetadata.levenshtein_distance @metadata[:year].to_s, article[:year].to_s

      m = []
      m << [td, 2.2] unless @metadata[:title].to_s.empty?
      m << [ad, 1.7] unless [@metadata[:authors]].flatten.join(";").empty?
      m << [yd, 1.0] unless @metadata[:year].to_s.empty?

      sum = m.inject(0.0){|s,x| s += x[1]}

      d = m.inject(0.0){|s,x| s+= x[0]*x[1]} / sum
      #p [td, ad, yd]
      #p d

      d
    end


    def to_text
      result = ""
      result += %~Id: #{@metadata[:id]}
Similarity: #{@metadata[:similarity]}
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
        a = ref.article
        result += %~
Ref.: #{idx+1}. #{[a[:authors]].flatten.join("; ")}: #{a[:title]}~
      end
      result += "\n\n"
      result
    end


    def to_xml
      result = %~
        <article id="#{::CGI.escapeHTML @metadata[:id].to_s}" year="#{::CGI.escapeHTML @metadata[:year].to_s}" lang="#{::CGI.escapeHTML @metadata[:language].to_s}">
            <publication>#{::CGI.escapeHTML @metadata[:publication].to_s}</publication>
            <title>#{::CGI.escapeHTML @metadata[:title].to_s}</title>
            <authors>~
      @metadata[:authors].to_a.each do |author|
        result += %~
                <author>#{::CGI.escapeHTML author}</author>~
      end
      result += %~
            </authors>
            <msc>~
      @metadata[:msc].to_a.each do |msc|
        result += %~
                <class>#{::CGI.escapeHTML msc}</class>~
      end
      result += %~
            </msc>
            <pages>#{::CGI.escapeHTML @metadata[:range].to_s}</pages>~
        @metadata[:issn].to_a.each do |issn|
          result += %~
            <issn>#{::CGI.escapeHTML issn}</issn>~
        end
        @metadata[:keywords].to_a.each do |keyword|
          result += %~
            <keyword>#{::CGI.escapeHTML keyword}</keyword>~
        end
        result += %~
            <references>
~
      @metadata[:references].to_a.each_with_index do |ref, idx|
        result += %~
                <reference id="#{::CGI.escapeHTML ref[:id].to_s}" number="#{::CGI.escapeHTML(ref[:number].to_s || (idx+1).to_s)}">
                    <authors>~
        [ref[:authors]].flatten.each do |author|
          result += %~
                        <author>#{::CGI.escapeHTML author}</author>~
        end
        result += %~
                    </authors>
                    <title>#{::CGI.escapeHTML ref[:title].to_s}</title>
                    <publication>#{::CGI.escapeHTML ref[:publication].to_s}</publication>
                    <publisher>#{::CGI.escapeHTML ref[:publisher].to_s}</publisher>
                    <year>#{::CGI.escapeHTML ref[:year].to_s}</year>
                </reference>
~
      end
      result += %~
            </references>
        </article>
~
      result
    end


    def to_html
      result = %~
    <div class="article">
        Id: <span class="id">#{::CGI.escapeHTML @metadata[:id].to_s}</span><br />
        Publication: <span class="publication">#{::CGI.escapeHTML @metadata[:publication].to_s}</span><br />
        Title: <span class="title">#{::CGI.escapeHTML @metadata[:title].to_s}</span><br />
        Authors: <span class="authors">#{::CGI.escapeHTML @metadata[:authors].to_a.join("; ")}</span><br />
        Year: <span class="year">#{::CGI.escapeHTML @metadata[:year].to_s}</span><br />
        Language: <span class="lang">#{::CGI.escapeHTML @metadata[:language].to_s}</span><br />
        MSC: <span class="msc">#{::CGI.escapeHTML @metadata[:msc].to_a.join("; ")}</span><br />
        Pages: <span class="pages">#{::CGI.escapeHTML @metadata[:range].to_s}</span><br />
        ISSN: <span class="issn">#{::CGI.escapeHTML @metadata[:issn].to_a.join('; ')}</span><br />
        Keywords: <span class="keywords">#{::CGI.escapeHTML @metadata[:keywords].to_a.join('; ')}</span><br />
        <a href="javascript:toggle_references('ref#{@metadata[:id]}')">References >>></a>
        <div id="ref#{@metadata[:id]}" name="ref#{@metadata[:id]}"class="references">
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
