require "../client"
require "../cache"
require "json"

module Leyline
  struct World
    include JSON::Serializable

    @[JSON::Field(converter: Leyline::IntToStrConverter)]
    getter id : String
    getter name : String
    getter population : String
  end

  class Cache
    @worlds = {} of String => Tuple(Time, World)

    def world(id : String)
      if element = @worlds[id]?
        time, object = element
        return nil if Time.now - time > 1.hour
        object
      end
    end

    def worlds
      # Reject out of date Worlds
      @worlds.reject { |_, _world| Time.now - _world[0] > 1.hour }
    end

    def cache_world(world)
      @worlds[world.id] = {Time.now, world}
    end

    def cache_worlds(_worlds : Array(World))
      time = Time.now
      _worlds.each { |q| cache_world(q, time) }
    end
  end

  class Client
    def world(id : String)
      _world = @cache.world(id)

      if _world.nil?
        _world = World.from_json(get("/worlds", {"id" => id}))
        @cache.cache_world(_world)
      end

      return _world
    end

    def world(id : Int32)
      world(id.to_s)
    end

    def worlds
      unless world_ids = @cache.id_list("/worlds")
        world_ids = Array(Int32).from_json(get("/worlds")).map(&.to_s)
        @cache.cache_id_list("/worlds", world_ids)
      end

      worlds(world_ids)
    end

    def worlds(list : Array(String))
      # Hash(String => Tuple(Time, World)) -> Hash(String => World)
      world_hash = @cache.worlds.transform_values { |_world| _world[1] }
      uncached = list - world_hash.keys

      Array(Leyline::World).from_json(get("/worlds", {"ids" => uncached.join(',')})).each do |_world|
        world_hash[_world.id] = _world
        @cache.cache_world(_world)
      end

      world_hash
    end
  end
end
