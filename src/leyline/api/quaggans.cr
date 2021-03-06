require "../client"
require "../cache"
require "./ids"

require "json"

module Leyline
  record Quaggan, id : String, url : String { include JSON::Serializable }

  class Cache
    generate_simple_cache(Quaggan, String)
  end

  class Client
    def quaggans : Hash(String, String)
      all_ids = @cache.id_list("/quaggans")

      if all_ids.nil?
        all_ids = Array(String).from_json(get("/quaggans"))
        @cache.cache_id_list("/quaggans", all_ids)
      end

      # Hash(String => Tuple(Time, Quaggan)) -> Hash(String => String)
      q_hash = @cache.quaggans.transform_values { |q| q[1].url }
      uncached = all_ids - q_hash.keys
      Array(Quaggan).from_json(get("/quaggans", {"ids" => uncached.join(',')})).each do |q|
        q_hash[q.id] = q.url
      end
      q_hash
    end

    def quaggan(id : String)
      quaggan = @cache.quaggan(id)
      if quaggan.nil?
        quaggan = Quaggan.from_json(get("/quaggans", {"id" => id}))
        @cache.cache_quaggan(quaggan)
      end

      return quaggan.url
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
        @cache.cache_quaggans(uncached_quaggans)
        uncached_quaggans.each do |quaggan|
          cached_quaggans[quaggan.id] = quaggan.url
        end
      end

      return cached_quaggans
    end
  end
end
