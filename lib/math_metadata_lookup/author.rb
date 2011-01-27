module MathMetadata

  class Author < Entity

    def to_text
      result = %~Id: #{@metadata[:id]}\nPreferred: #{@metadata[:preferred]}~
      @metadata[:forms].to_a.each do |form|
        result += %~
Other: #{form}~
      end
      result += "\n\n"
      result
    end


    def to_xml
      result = %~
        <author id="#{::CGI.escapeHTML(@metadata[:id])}">
            <name form="preferred">#{::CGI.escapeHTML(@metadata[:preferred].to_s)}</name>~
      @metadata[:forms].each do |form|
          result += %~
            <name form="other">#{::CGI.escapeHTML(form.to_s)}</name>~
      end
      result += %~
        </author>
~
      result
    end


    def to_html
      result = %~
    <div class="author">
        <div class="author_id"><span class="label">Id:</span> <span class="id">#{::CGI.escapeHTML(@metadata[:id])}</span></div>
        <div class="preferred"><span class="label">Preferred:</span> <span class="name">#{::CGI.escapeHTML(@metadata[:preferred].to_s)}</span></div>~

      @metadata[:forms].each do |form|
          result += %~
        <div class="other"><span class="label">Other:</span> <span class="name">#{::CGI.escapeHTML(form.to_s)}</span></div>~
      end

      result += %~
    </div>
~
      result
    end

  end

end
