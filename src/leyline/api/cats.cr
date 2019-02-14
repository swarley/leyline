require "../client"
require "json"

module Leyline
  struct Cat
    include JSON::Serializable

    @[JSON::Field(converter: Leyline::API::IntToStrConverter)]
    getter id : String

    getter hint : String
  end

  class Client
    def cat(id : String)
      @cat_cache[id]
      # Cat.from_json(get("/cats", {"id" => id.to_s}))
    end

    def cats : Array(String)
      return @id_cache["/cats"]
      # Array(Cat).from_json(get("/cats", {"id" => "all"}))
    end

    def cats(ids : Array(String)) : Array(Cat)
      @cat_cache[ids]
    end
  end
end

require "../client"
require "../cache"
require "json"

module Leyline
  class Client
    def quaggans(list = "all") : Hash(String, String)
      if list == "all"
        return @quaggan_cache[@id_cache["/quaggans"]] # .each do |quaggan|
        #   quaggan_hash[quaggan] = @quaggan_cache[quaggan]
        # end
        # return quaggan_hash
      end

      return quaggans(list.split(','))
    end

    def quaggans(list : Array(String))
      return @quaggan_cache[list]
    end
  end
end
