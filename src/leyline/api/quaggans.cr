require "../client"
require "../cache"
require "./ids"

require "json"

module Leyline
  record Quaggan, id : String, url : String { include JSON::Serializable }

  class Cache
    @quaggans = {} of String => Tuple(Time, Quaggan)
    getter quaggans

    def quaggan(id : String) : Quaggan | Nil
      if element = @quaggans[id]?
        time, object = element
        return nil if Time.now - time > 1.hour
        object
      end
    end

    def quaggan(ids : Array(String)) : Array(Quaggan)
      # TODO: This one needs more thought since, what should we do if we hit
      # an outdated value? Maybe we want to move the ability to self update back into
      # the cache logic?
    end

    def cache(quaggan : Quaggan, time = Time.now)
      @quaggans[quaggan.id] = {time, quaggan}
    end

    def cache(quaggans : Array(Quaggan))
      time = Time.now
      quaggans.each { |q| cache(q, time) }
    end
  end

  class Client
    def quaggans : Hash(String, String)
      all_ids = @cache.id_list("/quaggans")

      if all_ids.nil?
        all_ids = Array(String).from_json(get("/quaggans"))
        @cache.cache({ids: all_ids, endpoint: "/quaggans"})
      end

      quaggans(all_ids)
    end

    def quaggans(list : String)
      quaggans(list.split(/\s*,\s*/))
    end

    def quaggans(list : Array(String))
      cached_quaggans = {} of String => String
      uncached = [] of String
      list.each do |id|
        if quaggan = @cache.quaggan(id)
          cached_quaggans[id] = quaggan.url
        else
          uncached << id
        end
      end

      unless uncached.empty?
        uncached_quaggans = Array(Quaggan).from_json(get("/quaggans", {"ids" => uncached.join(',')}))
        @cache.cache(uncached_quaggans)
        uncached_quaggans.each do |quaggan|
          cached_quaggans[quaggan.id] = quaggan.url
        end
      end

      return cached_quaggans
    end
  end
end
