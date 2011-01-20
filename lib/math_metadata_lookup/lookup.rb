# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

module MathMetadata

  # Main class for searching through all sites
  class Lookup
    attr_accessor :options

    # :sites can be :all or array of allowed sites ([:mrev, :zbl])
    def initialize( opts={} )
      @options = { :sites => :all, :verbose => true }.merge(opts)
      @sites = []
    end

    # calls method for each site
    def method_missing(meth, *args)
      result = []

      sites = SITES.dup
      if (@options[:sites] != :all) or @options[:sites].kind_of?(Array)
        allowed = [@options[:sites]].flatten
        sites.delete_if{|s| not allowed.include?(s::CODE) }
      end

      sites.each do |klass|
        site = klass.new(:verbose => @options[:verbose])

        entry = {:site => klass::CODE, :name => klass::NAME, :url => klass::URL}
        entry[:result] = site.send(meth, *args)

        result << entry
      end

      Result.new(result)
    end


    # try to decide what is best result for query and combine results from all sites to one article response
    def heuristic( args={} )
      result = Result.new
      
      rs = {:name => "Heuristic Merge", :url => "", :results => []}

      sites = article(args)

      # joining articles
      articles = []
      query_article = Article.new( {:title => args[:title].to_s, :authors => args[:authors], :year => args[:year]} )
      sites.each do |site|
        site[:result].each do |article|
          next if article[:title].to_s.empty?
          next unless query_article == article
          article[:site] = site[:name]
          article[:distance] = query_article.distance(article)
          articles << article
        end
      end

      rs[:result] = articles.sort{|a| a[:distance]}

      result << rs
      result 
    end


  end # Lookup

end # module
