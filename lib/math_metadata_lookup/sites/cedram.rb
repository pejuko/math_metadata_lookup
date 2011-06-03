# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

require 'net/http'

module MathMetadata

  # NUMDAM
  # http://numdam.org/
  class CEDRAM < Site
    ID = :cedram
    NAME = "CEDRAM"
    URL = "http://cedram.org/"


    # AUTHOR_URL % "Author, Name"
    AUTHOR_URL = %~~

    AUTHORS_RE = %r{}mi
    AUTHOR_RE = %r{}mi


    ARTICLE_ID_URL = "http://aif.cedram.org/aif-bin/item?id=%s"
    ARTICLE_URL = "http://www.cedram.org/cedram-bin/search?ti=%s&au=%s&py1=%s&lang=en"
#    ARTICLE_URL = "http://www.cedram.org/cedram-bin/search"

    LIST_OF_ARTICLES_RE = %r{matches(.*?)</td>}mi
    ARTICLE_ENTRY_RE = %r{<a href="http://aif.cedram.org/aif-bin/item\?id=([^"]+)">Details</a>}mi
    ARTICLE_ID_RE = %r{<input type="hidden" name="id" value="([^"]+)" />}mi
    ARTICLE_TITLE_RE = %r{<span class="atitle">(.*?)</span>}mi
    ARTICLE_LANGUAGE_RE = %r{xxxxxxxxxxxxxxx}mi
    ARTICLE_AUTHORS_RE = %r{<head>\s*(.*?)\s*</head>}mi
    ARTICLE_AUTHOR_RE = %r{<meta content="([^"]+)" name="DC.creator">}mi
    ARTICLE_MSCS_RE = %r{Class. Math.:(.*?)<br}mi
    ARTICLE_MSC_RE = %r{([^,]+),?\s*}mi
    ARTICLE_PUBLICATION_RE = %r{(<span class="jtitle">.*?</span>,\s*<a href="http://aif.cedram.org:80/aif-bin/get\?id=[^"]+">\d+</a>\s*no\.\s*<a href="http://aif.cedram.org:80/aif-bin/browse\?id=[^"]+">\d+</a>\s*\(<a href="http://aif.cedram.org:80/aif-bin/get\?id=[^"]+">\d+</a>\))}mi
    ARTICLE_PUBLISHER_RE = %r{xxxxxxxxxxxxxxxxx}mi
    ARTICLE_RANGE_RE = %r{(\d+\-\d+)\s*<br\s*/>\s*Article}mi
    ARTICLE_YEAR_RE = %r{<span class="jtitle">.*?</span>,\s*<a href="http://aif.cedram.org:80/aif-bin/get\?id=[^"]+">\d+</a>\s*no\.\s*<a href="http://aif.cedram.org:80/aif-bin/browse\?id=[^"]+">\d+</a>\s*\(<a href="http://aif.cedram.org:80/aif-bin/get\?id=[^"]+">(\d+)</a>\)}mi
    ARTICLE_ISSNS_RE = %r{xxxxxxxxxxxxxxxxx}mi
    ARTICLE_ISSN_RE = %r{xxxxxxxxxxxxxxxxx}mi
    ARTICLE_KEYWORDS_RE = %r{Keywords:(.*?)<div}mi
    ARTICLE_KEYWORD_RE = %r{([^,]+),?\s*}mi
    ARTICLE_REFERENCES_RE = %r{<P>\s*<B>\s*Bibliography\s*</B>\s*</P>\s*</DIV>\s*(.*?)\s*</td>}mi
    ARTICLE_REFERENCE_RE = %r{\[\d+\](.*?)<BR>}mi

    def get_article_publication( page )
      page =~ ARTICLE_PUBLICATION_RE
      return nil unless $1
      $1.gsub(/<.*?>/, '')
    end

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


    def fetch_article( args={} )
      opts = {:id => nil, :title => "", :year => "", :authors => []}.merge(args)
      url = self.class::ARTICLE_ID_URL % URI.escape(opts[:id].to_s.strip)
      form = {'submit' => " Start search "}
      if opts[:id].to_s.strip.empty?
        author = join_article_authors opts[:authors]
        title = opts[:title]
        title = '' if not title.kind_of?(String)
        title = MathMetadata.normalize_text(title)
        title = nwords(title) if @options[:nwords]

        form['ti'] = title
        form['au'] = author unless author.empty?
        form['py1'] = opts[:year].to_s
        form['py2'] = ""
        form['pages'] = ""
        form['bibitems_text'] = ""
        form['maxdocs'] = "300"
        form['format'] = "short"
        form['ti_op'] = "and"
        form["au_op"] = "and"
        form["bibitems.text_op"] = "and"

        url = self.class::ARTICLE_URL % [URI.escape(title), author, opts[:year].to_s]
#        url = self.class::ARTICLE_URL
      else
        return fetch_page(url, opts)
      end
      
      uri = URI.parse(url)
      puts uri if opts[:verbose]
      req = Net::HTTP::Post.new(uri.path, {
        'Host' => "www.cedram.org",
        'User-Agent'=> "Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20110429 Firefox/4.0.1",
        'Accept' => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        'Accept-Language' => "cs,en;q=0.7,en-us;q=0.3",
        'Accept-Encoding' => "gzip, deflated",
        'Accept-Charset' => "UTF-8,*",
        'Keep-Alive' => "115",
        'Connection' => "keep-alive",
        'Referer' => "http://www.cedram.org/cedram-bin/search",
        'Content-Type' => "application/x-www-form-urlencoded",
      })
      req.set_form_data(form)
      http = Net::HTTP.new(uri.host, uri.port)
      resp = http.request(req)
      page = normalize_page resp.body
      page
    end

  end # MRev

end
