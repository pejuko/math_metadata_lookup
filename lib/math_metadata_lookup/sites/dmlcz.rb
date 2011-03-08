# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

module MathMetadata

  # Czech Digital Mathematics Library
  # http://dml.cz/
  # does not support author search
  class DMLCZ < Site
    ID = :dmlcz
    NAME = "DMLCZ"
    URL = "http://dml.cz/"


    # AUTHOR_URL % "Author, Name"
    AUTHOR_URL = %~~

    AUTHORS_RE = %r{}mi
    AUTHOR_RE = %r{}mi


    ARTICLE_ID_URL = "http://dml.cz/handle/10338.dmlcz/%s?show=full"
    ARTICLE_URL = "http://dml.cz/advanced-search?num_search_field=10&results_per_page=100&scope=%%2F&field1=title&query1=%s&%s&conjunction2=AND&field2=year&query2=%s&submit=Go"

    LIST_OF_ARTICLES_RE = %r{<ul class="bibliolist">(.*?)</ul>}mi
    ARTICLE_ENTRY_RE = %r{<li>.*?href="/handle/10338.dmlcz/(\d+)".*?</li>}mi
    #ARTICLE_ENTRY_RE = %r{<div class="headlineText">\s*<a href="/mathscinet/search/publdoc.html[^"]+">\s*<strong>\s*([^< ]+)\s*</strong>\s*<strong>}mi

    ARTICLE_ID_RE = %r{<meta\s*name="citation_id"\s*content="(\d+)"\s*/>}mi
    ARTICLE_TITLE_RE = %r{<meta\s*name="dc.Title"\s*content="([^"]+)"\s*/>}mi
    ARTICLE_LANGUAGE_RE = %r{<meta\s*name="citation_language"\s*content="([^"]+)"\s*/>}mi
    ARTICLE_AUTHORS_RE = %r{<meta\s*name="citation_authors"\s*content="([^"]+)" />}mi
    ARTICLE_AUTHOR_RE = %r{([^;]+);?\s*}mi
    ARTICLE_MSCS_RE = %r{<table\s*xmlns:fn="http://www.w3.org/2003/11/xpath-functions"\s*class="dml_detail_view">(.*?)</table>}mi
    ARTICLE_MSC_RE = %r{<tr>\s*<td\s*class="label">\s*MSC:\s*</td>\s*<td\s*class="value">\s*([^< ]+)\s*</td>\s*</tr>}mi
    ARTICLE_PUBLICATION_RE = %r{<meta\s*name="citation_journal_title"\s*content="([^"]+)"\s*/>}mi
    ARTICLE_RANGE_RE = %r{<tr>\s*<td class="label">\s*Pages:\s*</td>\s*<td\s*class="value">([^ <]+)</td>\s*</tr>}mi
    ARTICLE_YEAR_RE = %r{<meta\s*name="citation_year"\s*content="([^"]+)"\s*/>}mi
    ARTICLE_ISSNS_RE = %r{<head>(.*?)</head>}mi
    ARTICLE_ISSN_RE = %r{<meta\s*name="citation_issn"\s*content="([^"]+)"\s*/>}mi
    ARTICLE_KEYWORDS_RE = %r{<head>(.*?)</head>}mi
    ARTICLE_KEYWORD_RE = %r{<meta\s*name="citation_keywords"\s*content="([^"]+)"\s*/>}mi
    ARTICLE_REFERENCES_RE = %r{<table\s*xmlns:fn="http://www.w3.org/2003/11/xpath-functions"\s*class="dml_detail_view">(.*?)</table>}mi
    ARTICLE_REFERENCE_RE = %r{<tr>\s*<td class="label">Reference:\s*</td>\s*<td class="value">\s*\[[^\]]+\]\s*([^<]+)</td>\s*</tr>}mi

    def join_article_authors( authors )
      i = 2
      authors.collect { |author| 
        i += 1
        "conjunction#{i}=AND&field#{i}=author&query#{i}=#{URI.escape MathMetadata.normalize_name(author)}"
      }.join("&")
    end

  end # MRev

end
