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
        sites.delete_if{|s| not allowed.include?(s::ID) }
      end

      sites.each do |klass|
        site = klass.new(:verbose => @options[:verbose])

        entry = {:site => klass::ID, :name => klass::NAME, :url => klass::URL}
        entry[:result] = site.send(meth, *args)

        result << entry
      end

      Result.new(result)
    end


    # try to decide what is best result for query and combine results from all sites to one article response
    def heuristic( args={} )
      opts = {:threshold => 0.6}.merge(args)
      result = Result.new
      
      sites = article(args)

      query_article = Article.new( {:title => args[:title].to_s, :authors => args[:authors], :year => args[:year]} )
      sites.each do |site|
        site[:result].each do |article|
          next if article[:title].to_s.empty?
          article[:similarity] = query_article.similarity(article)
        end
        site[:result].delete_if{|a| a[:similarity].to_f < opts[:threshold].to_f}
        if site[:result].size > 0
          site[:result].sort!{|a| a[:similarity]}
          site[:result].reverse!
          site[:result] = [site[:result].first]
        end
      end

      sites
    end

  end # Lookup

end # module
