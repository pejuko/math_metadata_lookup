module MathMetadata

  # == Attributes
  #
  # * :id [String]
  # * :similarity [String]
  # * :publication [String]
  # * :title [String]
  # * :authors [Array of Strings]
  # * :year [String]
  # * :language [String]
  # * :msc [Array of Strings]
  # * :pages [String]
  # * :issn [Array of Strings]
  # * :keywords [Array of Strings]
  # * :references [Array of MathMetadata::Reference]
  class Article < Entity

    def ==(article)
      similarity(article) > 0.9
    end


    def similarity(article)
      td = MathMetadata.levenshtein_distance @metadata[:title].to_s, article[:title].to_s
      ad = MathMetadata.levenshtein_distance [@metadata[:authors]].flatten.sort.join(";"), [article[:authors]].flatten.sort.join(";")
      yd = MathMetadata.levenshtein_distance @metadata[:year].to_s, article[:year].to_s

      m = []
      m << [td, 2.8] unless @metadata[:title].to_s.empty?
      m << [ad, 1.4] unless [@metadata[:authors]].flatten.join(";").empty?
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
MSC: #{[@metadata[:msc]].flatten.join("; ")}
Pages: #{@metadata[:range]}
ISSN: #{@metadata[:issn].join('; ')}
Keywords: #{@metadata[:keywords].join('; ')}
Publisher: #{@metadata[:publisher]}~
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
                <author>#{::CGI.escapeHTML author.to_s}</author>~
      end
      result += %~
            </authors>
            <msc>~
      @metadata[:msc].to_a.each do |msc|
        result += %~
                <class>#{::CGI.escapeHTML msc.to_s}</class>~
      end
      result += %~
            </msc>
            <pages>#{::CGI.escapeHTML @metadata[:range].to_s}</pages>~
        @metadata[:issn].to_a.each do |issn|
          result += %~
            <issn>#{::CGI.escapeHTML issn.to_s}</issn>~
        end
        @metadata[:keywords].to_a.each do |keyword|
          result += %~
            <keyword>#{::CGI.escapeHTML keyword.to_s}</keyword>~
        end
        result += %~
            <publisher>#{::CGI.escapeHTML @metadata[:publisher].to_s}</publisher>
            <references>
~
      @metadata[:references].to_a.each_with_index do |reference, idx|
        ref = reference.article
        result += %~
                <reference id="#{::CGI.escapeHTML ref[:id].to_s}" number="#{::CGI.escapeHTML(ref[:number].to_s || (idx+1).to_s)}">
                    <source>#{::CGI.escapeHTML reference.source.to_s}</source>
                    <authors>~
        [ref[:authors]].flatten.each do |author|
          result += %~
                        <author>#{::CGI.escapeHTML author.to_s}</author>~
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
        <span class="label">Id:</span> <span class="id">#{::CGI.escapeHTML @metadata[:id].to_s}</span><br />
        <span class="label">Publication:</span> <span class="publication">#{::CGI.escapeHTML @metadata[:publication].to_s}</span><br />
        <span class="label">Title:</span> <span class="title">#{::CGI.escapeHTML @metadata[:title].to_s}</span><br />
        <span class="label">Authors:</span> <span class="authors">#{::CGI.escapeHTML @metadata[:authors].to_a.join("; ")}</span><br />
        <span class="label">Year:</span> <span class="year">#{::CGI.escapeHTML @metadata[:year].to_s}</span><br />
        <span class="label">Language:</span> <span class="lang">#{::CGI.escapeHTML @metadata[:language].to_s}</span><br />
        <span class="label">MSC:</span> <span class="msc">#{::CGI.escapeHTML @metadata[:msc].to_a.join("; ")}</span><br />
        <span class="label">Pages:</span> <span class="pages">#{::CGI.escapeHTML @metadata[:range].to_s}</span><br />
        <span class="label">ISSN:</span> <span class="issn">#{::CGI.escapeHTML @metadata[:issn].to_a.join('; ')}</span><br />
        <span class="label">Keywords:</span> <span class="keywords">#{::CGI.escapeHTML @metadata[:keywords].to_a.join('; ')}</span><br />
        <span class="label">Publisher:</span> <span class="publisher">#{::CGI.escapeHTML @metadata[:publisher].to_s}</span><br />
~
      if @metadata[:references].to_a.size > 0
        result += %~
        <a href="javascript:toggle_references('ref#{@metadata[:id]}')">References >>></a>
        <div id="ref#{@metadata[:id]}" name="ref#{@metadata[:id]}" class="references">
~
        @metadata[:references].to_a.each_with_index do |reference, idx|
          ref = reference.article
          result += %~
            <div class="reference">
                <span class="label">Source:</span> <span class="source">#{::CGI.escapeHTML reference.source.to_s}</span><br />
                <span class="label">Authors:</span> <span class="authors">#{::CGI.escapeHTML [ref[:authors]].flatten.join("; ")}</span><br />
                <span class="label">Title:</span> <span class="title">#{::CGI.escapeHTML ref[:title].to_s}</span><br />
                <span class="label">Publication:</span> <span class="publication">#{::CGI.escapeHTML ref[:publication].to_s}</span><br />
                <span class="label">Publisher:</span> <span class="publisher">#{::CGI.escapeHTML ref[:publisher].to_s}</span><br />
                <span class="label">Year:</span> <span class="year">#{::CGI.escapeHTML ref[:year].to_s}</span><br />
                <span class="label">Id:</span> <span class="id">#{::CGI.escapeHTML ref[:id].to_s}</span><br />
            </div>
~
        end
        result += %~
          </div>
~
      end
      result += %~
    </div>
~
      result
    end

  end # class

end # module
