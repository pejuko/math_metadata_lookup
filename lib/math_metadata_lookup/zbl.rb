# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

module MathMetadata

  # Zentralblatt
  # http://www.zentralblatt-math.org/zmath/
  class ZBL < Site
    CODE = :zbl
    NAME = "Zentralblatt"
    URL = "http://www.zentralblatt-math.org/zmath/"

    
    AUTHOR_URL ="http://www.zentralblatt-math.org/zbmath/authors/?q=%s"

    AUTHORS_RE = %r{<div class="name">\s*<strong>(.*?)</strong>.*?<div class="table">\s*<div class="title">Spellings:</div>\s*(.*?)\s*</div>}mi
    AUTHOR_RE = %r{(.*?)\s*\[\d+\](?:;\s*)?}
    
    
    ARTICLE_ID_URL = "http://www.zentralblatt-math.org/zmath/en/search?q=an:%s"
    ARTICLE_URL = "http://www.zentralblatt-math.org/zmath/en/search?q=ti:%s&au:%s"

    ARTICLE_ID_RE = %r{<a href="\?q=an:.*?complete">(.*?)</a>}mi
    ARTICLE_TITLE_RE = %r{</a><br>(.*?)\.</b>\s*\((.*?)\)<br>}mi
    ARTICLE_AUTHORS_RE = %r{<br><b>(<a href="\?q=[^"]*">.*?</a>)<br>}mi
    ARTICLE_AUTHOR_RE = %r{<a href="\?q=[^"]*">(.*?)</a>}mi
    ARTICLE_MSCS_RE = %r{<dd>(.*?)</dd>}mi
    ARTICLE_MSC_RE = %r{<a href=".*?">(.*?)</a>}mi
    ARTICLE_PROCEEDING_RE = %r{<a href="[^"j]*?journals[^"]*">(.*?)</a>}mi
    ARTICLE_RANGE_RE = %r{</a> \d+(?:-\d+)?,\s*(\d+-\d+).*?ISSN}
    ARTICLE_YEAR_RE = %r{</a>\s*\d+-\d+, \d+-\d+ \((\d+)\)\.}mi
    ARTICLE_ISSNS_RE = %r{(ISSN.*?)<br>}mi
    ARTICLE_ISSN_RE = %r{ISSN\s*(.........)}mi
    ARTICLE_KEYWORDS_RE = %r{<p><i>Keywords:</i>\s*(.*?)\s*</p>}mi
    ARTICLE_KEYWORD_RE = %r{([^;]+) ?}mi
  end # ZBL

end
