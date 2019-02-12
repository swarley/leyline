# This is a pretty pointless endpoint tbh.

require "json"
require "../client"

module Leyline
  class Client
    def nodes : Array(String)
      Array(String).from_json get("/nodes")
    end

    def node?(id : String) : Bool
      !JSON.parse(get("/nodes", {"id" => id}))["id"].nil?
    rescue Leyline::Exception => e
      return false
    end
  end
end
