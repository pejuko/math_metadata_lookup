# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

module MathMetadata

  # Bulgarian DML
  # does not support author search
  class BasBg < Site
    ID = :basbg
    NAME = "bas-bg"
    URL = "http://sci-gems.math.bas.bg:8080/jspui/"


    # AUTHOR_URL % "Author, Name"
    AUTHOR_URL = %~~

    AUTHORS_RE = %r{}mi
    AUTHOR_RE = %r{}mi


    ARTICLE_ID_URL = "http://sci-gems.math.bas.bg:8080/jspui/handle/%s"
    ARTICLE_URL = "http://sci-gems.math.bas.bg:8080/jspui/simple-search?query=%s&from_advanced=true"

    LIST_OF_ARTICLES_RE = %r{<table align="center" class="miscTable" summary="This table browses all dspace content">(.*?)</table>}mi
    ARTICLE_ENTRY_RE = %r{<tr>.*?href="/jspui/handle/([^"]+)".*?</tr>}mi
    #ARTICLE_ENTRY_RE = %r{<div class="headlineText">\s*<a href="/mathscinet/search/publdoc.html[^"]+">\s*<strong>\s*([^< ]+)\s*</strong>\s*<strong>}mi

    ARTICLE_ID_RE = %r{<meta\s*name="DC.identifier"\s*content="http://hdl.handle.net/([^"]+)".*?/>}mi
    ARTICLE_TITLE_RE = %r{<meta\s*name="dc.Title"\s*content="([^"]+)".*?/>}mi
    ARTICLE_LANGUAGE_RE = %r{<meta\s*name="dc.language"\s*content="([^"]+)".*?/>}mi
    ARTICLE_AUTHORS_RE = %r{<head>(.*?)</head>}mi
    ARTICLE_AUTHOR_RE = %r{<meta\s* name="dc.creator"\s*content="([^"]+)".*?/>}mi
    ARTICLE_MSCS_RE = %r{<meta.*?Classiﬁcation:\s*(.*?)\s*".*?/>}mi
    ARTICLE_MSC_RE = %r{([^,]+)}mi
    ARTICLE_PUBLICATION_RE = %r{<tr>\s*<td\s*class="metadataFieldLabel">\s*Appears in Collections:\s*</td><td\s*class="metadataFieldValue">\s*<a href="[^"]*">\s*(.*?)\s*</a>.*?</tr>}mi
    ARTICLE_PUBLISHER_RE = %r{<meta\s*name="DC.publisher"\s*content="([^"]+)".*?/>}mi
    ARTICLE_RANGE_RE = %r{<tr>\s*<td class="label">\s*Pages:\s*</td>\s*<td\s*class="value">([^ <]+)</td>\s*</tr>}mi
    ARTICLE_YEAR_RE = %r{td\s*class="metadataFieldLabel">\s*Issue Date:.*?</td>\s*<td\s*class="metadataFieldValue">\s*(.*?)\s*</td>}mi
    ARTICLE_ISSNS_RE = %r{<center><table\s*class="itemDisplayTable">(.*?)</table>}mi
    ARTICLE_ISSN_RE = %r{<td\s*class="metadataFieldLabel">\s*ISSN:.*?</td>\s*<td\s*class="metadataFieldValue">\s*(.*?)\s*</td>}mi
    ARTICLE_KEYWORDS_RE = %r{<head>(.*?)</head>}mi
    ARTICLE_KEYWORD_RE = %r{<meta\s*name="dc.subject"\s*content="([^"]+)".*?/>}mi
    ARTICLE_REFERENCES_RE = %r{<table\s*xmlns:fn="http://www.w3.org/2003/11/xpath-functions"\s*class="dml_detail_view">(.*?)</table>}mi
    ARTICLE_REFERENCE_RE = %r{<tr>\s*<td class="label">Reference:\s*</td>\s*<td class="value">\s*\[[^\]]+\]\s*([^<]+)</td>\s*</tr>}mi

    def build_article_url(title, author, year)
      prep_query = lambda{|prefix,str| str.to_s.split(/ +/).map{|t| "#{prefix}%3A#{URI.escape(t)}"}.join("+")}
      query = "((%s)+AND+(%s))" % [ prep_query.call("title", title), prep_query.call("author", author)]
      self.class::ARTICLE_URL % [query, author]
    end

    def join_article_authors( authors )
      authors.join(" ")
    end

  end

end
