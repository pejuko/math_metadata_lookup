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

    AUTHORS_RE = %r{<div class="name">\s*<strong>(.*?)</strong>.*?Author-Id:\s*</div>\s*([^ <]+)\s*</div>.*?<div class="table">\s*<div class="title">Spellings:</div>\s*(.*?)\s*</div>}mi
    AUTHOR_RE = %r{(.*?)\s*\[\d+\](?:;\s*)?}
    
    
    ARTICLE_ID_URL = "http://www.zentralblatt-math.org/zmath/en/search?q=an:%s"
    ARTICLE_URL = "http://www.zentralblatt-math.org/zmath/en/search?q=ti:%s%%26%s%%26py:%s"
    
    LIST_OF_ARTICLES_RE = %r{<strong class="middle">Result:</strong>}mi
    ARTICLE_ENTRY_RE = %r{<span[^>]*?>\s*<a href="\?q=an:([^\&]+)\&format=complete">[^<]+</a>\s*<b>}mi

    ARTICLE_ID_RE = %r{<a href="\?q=an:.*?complete">(.*?)</a>}mi
    ARTICLE_TITLE_RE = %r{</a><br>(.*?)\.</b>\s*\((.*?)\)<br>}mi
    ARTICLE_AUTHORS_RE = %r{<br><b>(<a href="\?q=[^"]*">.*?</a>)<br>}mi
    ARTICLE_AUTHOR_RE = %r{<a href="\?q=[^"]*">(.*?)</a>}mi
    ARTICLE_MSCS_RE = %r{<dd>(.*?)</dd>}mi
    ARTICLE_MSC_RE = %r{<a href=".*?">(.*?)</a>}mi
    ARTICLE_PUBLICATION_RE = %r{<a href="[^"j]*?journals[^"]*">(.*?)</a>}mi
    ARTICLE_RANGE_RE = %r{</a> \d+(?:-\d+)?,\s*(\d+-\d+).*?ISSN}
    ARTICLE_YEAR_RE = %r{</a>\s*\d+-\d+, \d+-\d+ \((\d+)\)\.}mi
    ARTICLE_ISSNS_RE = %r{(ISSN.*?)<br>}mi
    ARTICLE_ISSN_RE = %r{ISSN\s*(.........)}mi
    ARTICLE_KEYWORDS_RE = %r{<p><i>Keywords:</i>\s*(.*?)\s*</p>}mi
    ARTICLE_KEYWORD_RE = %r{([^;]+) ?}mi
    ARTICLE_REFERENCES_RE = %r{<p><i>Citations:</i>\s*(.*?)\s*</p>}
    # 1=authors, 2=journal, 3=volume/issue, 4=year, 5=range, 6=ref
    ARTICLE_REFERENCE_RE = %r{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
#<p><i>Citations:</i> <a href="?an=0962.76001">Zbl 0962.76001</a>; <a href="?an=0784.46029">Zbl 0784.46029</a>; <a href="?an=0974.46040">Zbl 0974.46040</a></p>

    protected

    def join_article_authors( authors )
      authors.collect { |author| "au:#{URI.escape author}" }.join("%26")
    end

    def get_article_references( page )
      page =~ self.class::ARTICLE_REFERENCES_RE
      ids = $1.to_s.gsub(/<.*?>/,'').gsub(/zbl /i,'').strip.split('; ')
      references = []
      ids.each do |id|
        references << article(:id => id, :format => :ruby, :references => false).first
      end
      references
    end

  end # ZBL

end
