require "../client"
require "json"

module Leyline
  struct Cat
    include JSON::Serializable

    getter id : Int32
    getter hint : String
  end

  class Client
    def cat(id : Int32)
      Cat.from_json(get("/cats", {"id" => id.to_s}))
    end

    def cats : Array(Int32)
      Array(Cat).from_json(get("/cats", {"id" => "all"}))
    end

    def cats(ids : Array(Int32)) : Array(Cat)
      Array(Cat).from_json("/cats", {"id" => ids.join(',')})
    end
  end
end
