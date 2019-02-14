module Leyline
  struct CacheData(T)
    property data : T
    property last_updated : Time

    def initialize(@data, @last_updated = Time.now)
    end
  end

  class Cache(T)
    # This shouldn't change, and if it does we can reevaluate later
    LEASE_TIME = Time::Span.new(1, 0, 0)

    # This block is called to cache a key
    def initialize(@single : String -> T, @multiple : (Array(String) -> Hash(String, CacheData(T)))? = nil)
      @data = {} of String => CacheData(T)
    end

    def []=(key : String, value : T)
      @data[key] = CacheData(T).new(data: value, last_updated: Time.now)
      return value
    end

    def [](key : String)
      cache_data = @data[key]?

      if cache_data.nil?
        @data[key] = CacheData(T).new(data: @single.call(key), last_updated: Time.now)
      elsif Time.now >= cache_data.last_updated + LEASE_TIME || cache_data.nil?
        @data[key].data = @single.call(key)
      end

      return @data[key].data
    end

    def [](list : Array(String))
      return {} of String => T if @multiple.nil?

      uncached = [] of String
      list.each do |key|
        uncached << key unless @data[key]?
      end
      ret_data = {} of String => T
      (list - uncached).each do |key|
        ret_data[key] = @data[key].data
      end

      new_data = @multiple.as(Proc(Array(String), Hash(String, CacheData(T)))).call(uncached)
      @data.merge! new_data

      uncached.each do |key|
        ret_data[key] = self[key]
      end

      return ret_data
    end
  end
end
