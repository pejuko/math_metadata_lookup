# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

module MathMetadata

  # Mathematical Reviews
  # http://www.ams.org/mr-database
  class MR < Site
    ID = :mr
    NAME = "MathSciNet"
    URL = "http://www.ams.org/mr-database"


    # AUTHOR_URL % "Author, Name"
    AUTHOR_URL = %~http://www.ams.org/mathscinet/search/authors.html?authorName=%s&Submit=Search~

    AUTHORS_RE = %r{<h1 class="profileHead">(.*)<\/h1>.*?<li>\s*MR Author ID:\s*<b>\s*(\d+)\s*</b></li>(?:.*?<ul class="variations">(.*?)<\/ul>)?}mi
    AUTHOR_RE = %r{<li>(.*?)<\/li>}mi


    ARTICLE_ID_URL = "http://www.ams.org/msnmain?preferred_language=en&pg3=MR&s3=%s&l=20&reference_lists=show&simple_headlines=full&contributed_items=show&redirect=Providence%%2C+RI+USA&Submit=Start+Search&fn=130&form=basicsearch"
#    ARTICLE_URL = "http://www.ams.org/mathscinet/search/publications.html?pg4=TI&s4=%s&co4=AND&%s&Submit=Search&dr=all&yrop=eq&arg3=%s&dr=pubyear&yearRangeFirst=&yearRangeSecond=&pg8=ET&s8=All&review_format=html"
    #ARTICLE_URL = "http://www.ams.org/mathscinet/search/publdoc.html?co4=AND&dr=pubyear&pg4=TI&pg8=ET&r=1&review_format=html&s4=%s&%s&All&vfpref=html&yearRangeFirst=&yearRangeSecond=&yrop=eq&arg3=%s"
    ARTICLE_URL = "http://www.ams.org/mathscinet/search/publications.html?co4=AND&dr=pubyear&pg4=TI&pg8=ET&r=1&review_format=html&s4=%s&%s&All&vfpref=html&yearRangeFirst=&yearRangeSecond=&yrop=eq&arg3=%s"

    LIST_OF_ARTICLES_RE = %r{<strong>Matches:</strong>\s*\d*}mi
    ARTICLE_ENTRY_RE = %r{<div class="headlineText">\s*<a href="/mathscinet/search/publdoc.html[^"]+">\s*<strong>\s*([^< ]+)\s*</strong>\s*<strong>}mi

    ARTICLE_ID_RE = %r{<strong>(.*?)</strong>}mi
    ARTICLE_TITLE_RE = %r{<span class="title">(?:<span class="searchHighlight">)?(.*?)</span>}mi
    ARTICLE_LANGUAGE_RE = %r{<span class="sumlang">\s*\(?(.*?)\)?\s*</span>?}mi
    ARTICLE_AUTHORS_RE = %r{<br />(<a href="/mathscinet/search/publications.html[^"]*">.*?</a>)<br />}mi
    ARTICLE_AUTHOR_RE = %r{<a href="/mathscinet/search/publications.html[^"]*">(.*?)</a>}mi
    ARTICLE_MSCS_RE = %r{<a href="/mathscinet/search/mscdoc.html\?code=[^"]*">(.*?)</a>}mi
    ARTICLE_MSC_RE = %r{([^, ]+)}mi
    ARTICLE_PUBLICATION_RE = %r{<a href="/mathscinet/search/journaldoc\.html\?cn=[^"]*">\s*<em>(.*?)</em>\s*</a>}mi
    ARTICLE_PUBLISHER_RE = %r{xxxxxxxxxxxxxxxxxx}mi
    ARTICLE_RANGE_RE = %r{(\d+–\d+)}mi
    ARTICLE_YEAR_RE = %r{<a href="/mathscinet/search/publications\.html[^"]*">\s*\(?(\d{4})\)?, </a>}mi
    ARTICLE_ISSNS_RE = %r{(ISSN.*?)<br>}mi
    ARTICLE_ISSN_RE = %r{ISSN\s*(.........)}mi
    ARTICLE_KEYWORDS_RE = %r{<p><i>Keywords:</i>\s*(.*?)\s*</p>}mi
    ARTICLE_KEYWORD_RE = %r{([^;]) ?}mi
    #ARTICLE_REFERENCES_RE = %r{<center>\s*<strong>\s*References\s*</strong>\s*</center>\s*<ol>\s*(.*?)\s*</ol>}mi
    ARTICLE_REFERENCES_RE = %r{<center>\s*<strong>\s*References\s*</strong>\s*</center>\s*<ol>\s*(.*?)\s*</ol>}mi
    ARTICLE_REFERENCE_RE = %r{<li>\s*([^:]+:.*?)\s*</li>}

    #ARTICLE_REFERENCE_RE = %r{([^:]+):(.*?)\s*<span class="bf">\s*(.*?)\s*<\/span>\s*\((\d+)\)\s*(?:,\s*([^ ]+?)\s*<a href="[^"]+"\s*>\s*([^ ]+)\s*.*?)?}mi
    #
    def join_article_authors( authors )
      i = 4
      authors.collect { |author| 
        i += 1
        "pg#{i}=AUCN&s#{i}=#{URI.escape MathMetadata.normalize_name(author)}&co#{i}=AND"
      }.join("&")
    end

    def get_article_references( page )
      refs = super page
      refs.each do |r|
        r.source =~ /(MR[^\s]+)/
        r.article[:id] = $1
      end
      refs 
    end

  end # MRev

end
