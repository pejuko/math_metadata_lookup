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
            <name form="preferred">#{::CGI.escapeHTML(@metadata[:preferred])}</name>~
      @metadata[:forms].each do |form|
          result += %~
            <name form="other">#{::CGI.escapeHTML(form)}</name>~
      end
      result += %~
        </author>
~
      result
    end


    def to_html
      result = %~
    <div class="author">
        <div class="author_id">Id: #{::CGI.escapeHTML(@metadata[:id])}</div>
        <div class="preferred">Preferred: #{::CGI.escapeHTML(@metadata[:preferred])}</div>~

      @metadata[:forms].each do |form|
          result += %~
        <div class="other">Other: #{::CGI.escapeHTML(form)}</div>~
      end

      result += %~
    </div>
~
      result
    end

  end

end