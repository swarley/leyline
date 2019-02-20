# This is a pretty pointless endpoint tbh.

require "json"
require "../client"

module Leyline
  class Cache
    alias NodeCache = NamedTuple(list: Array(String), time: Time)
    @nodes = {list: [] of String, time: Time::UNIX_EPOCH}

    # Returns nil if the node cache is out of date
    def node(key : String)
      return nil if Time.now - @nodes.time > 1.hour
      @nodes[:list].includes? key
    end

    def node_list
      return nil if Time.now - @nodes[:time] > 1.hour
      @nodes[:list]
    end

    def cache_nodes(nodes : Array(String))
      @nodes = {list: nodes, time: Time.now}
    end
  end

  class Client
    def nodes : Array(String)
      node_list = @cache.node_list
      if node_list.nil?
        node_list = Array(String).from_json(get("/nodes"))
        @cache.cache_nodes(node_list)
      end

      return node_list
    end

    def node?(id : String) : Bool
      unless node_list = @cache.node_list
        node_list = Array(String).from_json(get("/nodes"))
        @cache.cache_nodes(node_list)
      end
      node_list.includes? id
    end
  end
end
