module Leyline
  struct CacheData(T)
    property data : T
    property last_updated : Time

    def initialize(@data, @last_updated)
    end
  end

  class Cache(T)
    # This shouldn't change, and if it does we can reevaluate later
    LEASE_TIME = Time::Span.new(1, 0, 0)

    # This block is called to cache a key
    def initialize(&@cache_block : String -> T)
      # @cache_block = block
      @data = {} of String => CacheData(T)
    end

    def []=(key : String, value : T)
      @data[key] = CacheData(T).new(data: value, last_updated: Time.now)
      return value
    end

    def [](key : String)
      cache_data = @data[key]?

      if cache_data.nil?
        @data[key] = CacheData(T).new(data: @cache_block.call(key), last_updated: Time.now)
      elsif Time.now >= cache_data.last_updated + LEASE_TIME || cache_data.nil?
        @data[key].data = @cache_block.call(key)
      end

      return @data[key].data
    end
  end
end
