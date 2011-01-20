module MathMetadata

  class Entity

    def initialize( meta={} )
      @metadata = meta.dup
    end

    def method_missing( meth, *args )
      case meth.to_s
      when /(.*?)=/
        self[$1] = args.first
      else
        self[meth]
      end
    end

    def [](key)
      @metadata[key.to_sym]
    end

    def []=(key, value)
      @metadata[key.to_sym] = value
    end

    def format( f=:ruby )
      result = self

      case f.to_sym
      when :text, :html, :xml
        result = self.send("to_#{f}")
      end

      result
    end

  end

end
