# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

require 'rexml/document'

module MathMetadata

  # NUMDAM
  # http://numdam.org/
  class NUMDAM< Site
    ID = :numdam
    NAME = "NUMDAM"
    URL = "http://numdam.org/"


    # AUTHOR_URL % "Author, Name"
    AUTHOR_URL = %~~

    AUTHORS_RE = %r{}mi
    AUTHOR_RE = %r{}mi


    ARTICLE_ID_URL = "http://www.numdam.org/numdam-bin/item?id=%s"
    ARTICLE_URL = "http://dml.cz/advanced-search?num_search_field=10&results_per_page=100&scope=%%2F&field1=title&query1=%s&%s&conjunction2=AND&field2=year&query2=%s&submit=Go"
    ARTICLE_URL = "http://www.numdam.org/numdam-bin/search?bibitems.au_op=and&bibitems.text_op=and&ti=%s&au=%s&ti_op=and&Index1.y=0&Index1.x=0&bibitems.ti_op=and&au_op=and&py1=%s"

    LIST_OF_ARTICLES_RE = %r{<P>\s*<DIV\s+align="center">.*?</DIV>\s*</P>\s*(.*?)\s*<P>\s*<DIV\s+align="center">.*?</DIV>\s*</P>}mi
    ARTICLE_ENTRY_RE = %r{<a href="http://www.numdam.org:80/numdam-bin/item\?id=([^"]+)">Full entry</a>}mi

    ARTICLE_ID_RE = %r{<P>stable URL: http://www.numdam.org/item\?id=([^<]+)</P>}mi
    ARTICLE_TITLE_RE = %r{<SPAN class="atitle">(.*?)</SPAN>}mi
    ARTICLE_LANGUAGE_RE = %r{xxxxxxxxxxxxxxx}mi
    ARTICLE_AUTHORS_RE = %r{<head>\s*(.*?)\s*</head>}mi
    ARTICLE_AUTHOR_RE = %r{<meta content="([^"]+)" name="DC.creator">}mi
    ARTICLE_MSCS_RE = %r{xxxxxxxxxxxxxxxxx}mi
    ARTICLE_MSC_RE = %r{xxxxxxxxxxxxxxx}mi
    ARTICLE_PUBLICATION_RE = %r{<SPAN class="jtitle">(.*?)</SPAN>}mi
    ARTICLE_PUBLISHER_RE = %r{xxxxxxxxxxxxxxxxx}mi
    ARTICLE_RANGE_RE = %r{(\d+\-\d+)\s*<BR>\s*Full text}mi
    ARTICLE_YEAR_RE = %r{py=(\d+)}mi
    ARTICLE_ISSNS_RE = %r{xxxxxxxxxxxxxxxxx}mi
    ARTICLE_ISSN_RE = %r{xxxxxxxxxxxxxxxxx}mi
    ARTICLE_KEYWORDS_RE = %r{xxxxxxxxxxxxxxxxx}mi
    ARTICLE_KEYWORD_RE = %r{xxxxxxxxxxxxxxxxx}mi
    ARTICLE_REFERENCES_RE = %r{<P>\s*<B>\s*Bibliography\s*</B>\s*</P>\s*</DIV>\s*(.*?)\s*</td>}mi
    ARTICLE_REFERENCE_RE = %r{\[\d+\](.*?)<BR>}mi

    def get_article_references( page )
      references = []

      refs = get_article_reference_s page

      i = 0;
      refs.each do |r|
        i+=1
        ref = Reference.new nil, i
        ref.source = r.gsub(/  +/,' ')
        ref.article = Article.new

        r =~ %r{<span class="atitle">(.*?)</span>}im
        ref.article.title = $1.to_s.strip

        ref.article.authors = []
        r.split(%r{<span class="bauteur">\s?(.*?)\s*</span>}).each do |a|
          next if a.strip.empty? or a.strip == "-" or a.strip[0,1] == ','
          author = a.gsub /<.*?>/, ''
          ref.article.authors << author
        end

        r =~ %r{<span class="brevue">(.*?)</span>}mi
        ref.article.publication = $1.strip if $1

        r =~ %r{<bediteur>(.*?)</bediteur>}mi
        ref.article.publisher = $1.strip if $1

        r =~ %r{<blieued>(.*?)</blieued>}mi
        ref.article.place = $1.strip if $1

        r =~ %r{<bannee>(.*?)</bannee>}mi
        ref.article.year = $1.strip if $1

        r =~ %r{<bpagedeb>(\d+)</bpagedeb>-<bpagefin>(\d+)</bpagefin>}mi
        ref.article.range = "#{$1.strip}-#{$2.strip}" if $1

        references << ref
      end

      references
    end

  end # MRev

end
