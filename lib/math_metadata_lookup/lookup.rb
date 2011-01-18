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

      result
    end
  end # Lookup

end # module
