require "../client"
require "json"

module Leyline
  struct Cat
    include JSON::Serializable

    @[JSON::Field(converter: Leyline::API::IntToStrConverter)]
    getter id : String
    getter hint : String
  end

  class Cache
    @cats = {} of String => Tuple(Time, Cat)
    getter cats

    # TODO: Things like this and quaggans can be made into a
    # `simple_cache` macro since they use the exact same logic
    def cat(id : String) : Cat | Nil
      if element = @cats[id]?
        time, object = element
        return nil if Time.now - time > 1.hour
        object
      end
    end

    # TODO cluster fuck
    def cat(ids : Array(String)) : Array(Cat)
      # Don't return out of date ids
      @cats.reject { |c| Time.now - c[0] > 1.hour }
    end

    def cache_cat(cat : Cat, time = Time.now)
      @cats[cat.id] = {time, cat}
    end

    def cache_cats(cats : Array(Cat))
      time = Time.now
      cats.each { |c| cache_cat(c, time) }
    end
  end

  class Client
    def cat(id : String)
      unless cat = @cache.cat(id)
        cat = get("/cat", {"id" => cat})
        @cache.cache_cat(cat)
      end
      cat
    end

    def cats : Array(String)
      unless cat_ids = @cache.id_list("/cats")
        cat_ids = Array(String).from_json(get("/cats"))
        @cache.cache_id_list("/cats", cat_ids)
      end

      cats(cat_ids)
    end

    # TODO: Implement this and `Client#worlds(Array(String))` at the same time
    def cats(id_list : Array(String)) : Array(Cat)
      cat_hash = @cache.cats.transform_values {|_cat| _cat[1]}
      uncached = id_list - cat_hash.keys

      Array(Leyline::Cat).from_json(get("/cats", {"ids" => uncached.join(',')})).each do |_cat|
        cat_hash[_cat.id] = _cat
        @cache.cache_cat(_cat)
      end

      cat_hash
    end
  end
end
