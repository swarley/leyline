require "../client"
require "../cache"

module Leyline
  class Cache
    @ids = {} of String => Tuple(Time, Array(String))
    getter ids

    def id_list(endpoint : String)
      if element = @ids[endpoint]?
        time, object = element
        return nil if Time.now - time > 1.hour
        object
      end
    end

    def cache_id_list(endpoint : String, ids : Array(String))
      @ids[endpoint] = {Time.now, ids}
    end
  end
end
