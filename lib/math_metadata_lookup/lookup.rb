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
        site = klass.new(:verbose => @options[:verbose], :nwords => args[0][:nwords])

        entry = {:site => klass::ID, :name => klass::NAME, :url => klass::URL}
        entry[:result] = site.send(meth, *args)

        result << entry
      end

      Result.new(result)
    end


    # returns best result for each site
    def heuristic( args={} )
      opts = {:threshold => 0.6, :authors => []}.merge(args)
      result = Result.new
      
      # use only authors surnames
      args_dup = opts.dup
      args_dup[:authors].map!{|a| a =~ /([^,]+)/; $1 ? $1 : a}
      args_dup[:authors].map!{|a| a =~ /([^ ]+) \S+/; $1 ? $1 : a}
      args_dup[:nwords] = 2
      sites = article(args_dup)

      # query article has to contain full names
      query_article = Article.new( {:title => args[:title].to_s, :authors => args[:authors], :year => args[:year]} )
      sites.each do |site|
        site[:result].to_a.each do |article|
          next if article[:title].to_s.empty?
          article[:similarity] = query_article.similarity(article)
        end
        site[:result].to_a.delete_if{|a| a[:similarity].to_f < opts[:threshold].to_f}
        if site[:result].to_a.size > 0
          site[:result].sort!{|a,b| a[:similarity]<=>b[:similarity]}
          site[:result].reverse!
          site[:result] = [site[:result].to_a.first]
        end
      end

      sites
    end


    # parse reference string and execute heuristic to query for article in databases
    def reference( args={} )
      ref = Reference.new args[:reference]
      pp ref if args[:verbose]

      opts = {:threshold => 0.6}.merge(args)
      opts[:title] = ref.article[:title]
      opts[:authors] = ref.article[:authors]
      opts[:year] = ref.article[:year]

      heuristic opts
    end

  end # Lookup

end # module
