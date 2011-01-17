# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

module MathMetadata

  # Mathematical Reviews
  # http://www.ams.org/mr-database
  class MRev < Site
    CODE = :mrev
    NAME = "Mathematical Reviews"
    URL = "http://www.ams.org/mr-database"


    AUTHOR_URL = %~http://www.ams.org/mathscinet/search/authors.html?authorName=%s&Submit=Search~

    AUTHORS_RE = /<h1 class="profileHead">(.*)<\/h1>(?:.*?<ul class="variations">(.*?)<\/ul>)?/m
    AUTHOR_RE = /<li>(.*)<\/li>/


    ARTICLE_ID_URL = "http://www.ams.org/msnmain?preferred_language=en&pg3=MR&s3=%s&l=20&reference_lists=show&simple_headlines=full&contributed_items=show&redirect=Providence%%2C+RI+USA&Submit=Start+Search&fn=130&form=basicsearch"
    ARTICLE_URL = "http://www.ams.org/mathscinet/search/publdoc.html?arg3=&co4=AND&co5=AND&co6=AND&co7=AND&dr=all&pg4=TI&pg5=AUCN&pg6=PC&pg7=ALLF&pg8=ET&r=1&s4=%s&s5=%s&s6=&s7=&s8=All&yearRangeFirst=&yearRangeSecond=&yrop=eq"

    ARTICLE_ID_RE = %r{<strong>(.*?)</strong>}mi
    ARTICLE_TITLE_RE = %r{<span class="title">(?:<span class="searchHighlight">)?(.*?)</span>.*?<span class="sumlang">\(?(.*?)\)?</span>}mi
    ARTICLE_AUTHORS_RE = %r{<br />(<a href="/mathscinet/search/publications.html[^"]*">.*?</a>)<br />}mi
    ARTICLE_AUTHOR_RE = %r{<a href="/mathscinet/search/publications.html[^"]*">(.*?)</a>}mi
    ARTICLE_MSCS_RE = %r{<a href="/mathscinet/search/mscdoc.html\?code=[^"]*">(.*?)</a>}mi
    ARTICLE_MSC_RE = %r{([^, ]+)}mi
    ARTICLE_PROCEEDING_RE = %r{<a href="/mathscinet/search/journaldoc\.html\?cn=[^"]*">\s*<em>(.*?)</em>\s*</a>}mi
    ARTICLE_RANGE_RE = %r{(\d+–\d+)}mi
    ARTICLE_YEAR_RE = %r{<a href="/mathscinet/search/publications\.html[^"]*">\s*\(?(\d{4})\)?, </a>}mi
    ARTICLE_ISSNS_RE = %r{(ISSN.*?)<br>}mi
    ARTICLE_ISSN_RE = %r{ISSN\s*(.........)}mi
  end # MRev

end
