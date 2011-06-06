# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

module MathMetadata

  # == Attributes
  #
  # * :source [String] original string
  # * :article [MathMetadata::Article] parsed metadata
  class Reference

    # 1=authors, 2=title, 3=publication, 4=year, 5=range
    ARTICLE_REFERENCE_1_RE = %r{([^:]+):\s*(.*?),\s*([^,]+),\s*\((\d{4})\)\s*,\s*([^ ]+)\s*.*?}mi
    # 1=authors, 2=title, 3=publication, 4=range, 5=publisher, 6=place, 7=year
    ARTICLE_REFERENCE_2_RE = %r{([^:]+):\s*(.*?),\s*(.*?,\s*[^,]+,\s*[^,]+,\s*[^,]+),\s*pp\.\s*([^,]+?),\s*([^,]+),\s*(.*?),\s*(\d{4})\s*.*?}mi
    # 1=authors, 2=title, 3=range, 4=publication, 5=place, 6=year
    ARTICLE_REFERENCE_3_RE = %r{([^:]+):\s*(.*?),\s*pp\.\s*([^,]+?),\s*([^,]+),\s*(.*?),\s*(\d{4})}mi
    # 1=authors, 2=title, 3=publication, 4=publisher, 5=place, 6=year
    ARTICLE_REFERENCE_4_RE = %r{([^:]+):\s*(.*?),\s*(.*?),\s*([^,]+),\s*([^,]+),\s*(\d{4})\s*.*?}mi
    # 1=authors, 2=title, 4=publisher, 5=place, 6=year
    ARTICLE_REFERENCE_5_RE = %r{([^:]+):\s*(.*?),\s*(.*?),\s*([^,]+),\s*(\d{4})\s*.*?}mi
    # 1=authors, 2=title, 3=publisher, 4=place, 5=year
    ARTICLE_REFERENCE_6_RE = %r{([^:]+):\s*(.*?),\s*([^,]+),\s*([^,]+),\s*(\d{4})\s*}mi
    # 1=authors, 2=title, 3=publication, 4=year, 5=range
    ARTICLE_REFERENCE_7_RE = %r{([^:]+):\s*(.*),\s*(.*?,\s*\d+)\s*\((\d{4})\),\s*([^ ]+)\s*.*?}mi
    # 1=authors, 2=title, 3=publication, 4=year, 5=range
    ARTICLE_REFERENCE_8_RE = %r{([^:]+):\s*(.*),\s*(.*?)\s*\((\d{4})\),\s*([^ ]+)\s*.*?}mi
    # 1=authors, 2=title, 3=publisher, 4=place
    ARTICLE_REFERENCE_9_RE = %r{([^:]+):\s*(.*?),\s*([^,]+),\s*(.*)}mi
    # 1=authors, 2=title, 3=publication
    ARTICLE_REFERENCE_10_RE = %r{([^:]+):\s*(.*?),\s*(.*?)\s*.*?}mi
    # 1=authors, 2=title, 3=place, 4=year
    ARTICLE_REFERENCE_11_RE = %r{([^:]+):\s*(.*),(.*?)\s+(\d{4})}mi


    attr_accessor :source, :article, :suffix, :number, :reg

    def initialize( str=nil, i=1 )
      @number = i
      if str.kind_of?(Article)
        @source = @suffix = nil
        @article = str
      else
        @source = str
        @article, @suffix = Reference.parse(str) unless str.to_s.empty?
      end
    end


    def to_json(*args)
      {
        :number => @number,
        :source => @source,
        :article => @article
      }.to_json(*args)
    end


    def self.parse( ref_str )
      str = ref_str.dup
      if ref_str =~ %r~\s*[\[\(\{\/\\].*?[\]\)\}\/\\][:\.]?\s*(.*)~mi
        str = $1
      end
      article = Article.new
      rnumber = 0
      suffix = nil
      found = []
      (1..11).each do |j|
        # 1=authors, 2=title, 3=publication, 4=year, 5=range, 6=id, 7=place, 8=publisher
        re = eval("Reference::ARTICLE_REFERENCE_#{j}_RE")
        if str =~ re
          case j
          when 1
            # 1=authors, 2=title, 3=publication, 4=year, 5=range, 6=id
            found = [$1, $2, $3, $4, MathMetadata.normalize_range($5), nil]
          when 2
            # 1=authors, 2=title, 3=publication, 4=range, 5=publisher, 6=place, 7=year, 8=id
            found = [$1, $2, $3, $7, MathMetadata.normalize_range($4), nil, $6, $5]
          when 3
            # 1=authors, 2=title, 3=range, 4=publication, 5=place, 6=year
            found = [$1, $2, $4, $6, MathMetadata.normalize_range($3), nil, $5]
          when 4
            # 1=authors, 2=title, 3=publication, 4=publisher, 5=place, 6=year, 7=id
            found = [$1, $2, $3, $6, nil, nil, $5, $4]
          when 5
            # 1=authors, 2=title, 3=publisher, 4=place, 5=year, 6=id
            found = [$1, $2, nil, $5, nil, nil, $4, $3]
          when 6
            # 1=authors, 2=title, 3=publisher, 4=place, 5=year, 6=id
            found = [$1, $2, nil, $5, nil, nil, $4, $3]
          when 7
            # 1=authors, 2=title, 3=publication, 4=year, 5=range, 6=id
            found = [$1, $2, $3, $4, MathMetadata.normalize_range($5), nil]
          when 8
            # 1=authors, 2=title, 3=publication, 4=year, 5=range, 6=id
            found = [$1, $2, $3, $4, MathMetadata.normalize_range($5), nil]
          when 9
            # 1=authors, 2=title, 3=publisher, 4=place
            found = [$1, $2, nil, nil, nil, nil, $4, $3]
          when 10
            # 1=authors, 2=title, 3=publication, 4=id
            found = [$1, $2, $3, nil, nil, nil, nil, nil]
          when 11
            # 1=authors, 2=title, 3=place, 4=year
            found = [$1, $2, nil, $4, nil, nil, $3]
          end
          rnumber = j
          break
        end
      end

      [:authors, :title, :publication, :year, :range, :id, :place, :publisher].each_with_index do |key, idx|
        article[key] = found[idx]
      end
      article.authors = Reference.split_authors article.authors

      [article, suffix, rnumber]
    end


    def self.split_authors( str )
      res = [
        /;\s*/,
        /,?\s*(?:and|und|et)\s+/,
        /(\S+,\s*[^,]+),?\s*/
      ]

      authors = [str]
      res.each do |re|
        authors = authors.map{|a| a.to_s.split(re)}.flatten
      end
      authors.delete_if{|a| a.strip.empty?}

      authors
    end

  end

end
