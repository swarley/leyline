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
    generate_simple_cache(Cat, String)
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
      cat_hash = @cache.cats.transform_values { |_cat| _cat[1] }
      uncached = id_list - cat_hash.keys

      Array(Leyline::Cat).from_json(get("/cats", {"ids" => uncached.join(',')})).each do |_cat|
        cat_hash[_cat.id] = _cat
        @cache.cache_cat(_cat)
      end

      cat_hash
    end
  end
end
