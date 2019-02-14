require "../cache"
require "json"

module Leyline
  alias PermissionTuple = NamedTuple(account: Bool, build: Bool, characters: Bool, guilds: Bool, inventories: Bool, progression: Bool, pvp: Bool, tradingpost: Bool, unlocks: Bool, wallet: Bool)

  module PermissionTupleConverter
    def self.from_json(parser : JSON::PullParser)
      perm_hash = {
        "account" => false,
        "build" => false,
        "characters" => false,
        "guilds" => false,
        "inventories" => false,
        "progression" => false,
        "pvp" => false,
        "tradingpost" => false,
        "unlocks" => false,
        "wallet" => false
      }

      parser.read_array do
        perm_hash[parser.read_string] = true
      end
      return PermissionTuple.from(perm_hash)
    end
  end

  struct TokenInfo
    include JSON::Serializable

    getter id : String
    getter name : String
    @[JSON::Field(converter: Leyline::PermissionTupleConverter)]
    getter permissions : PermissionTuple

    def initialize(@id, @name, @permissions)
    end
  end

  class Client
    NO_PERMS = PermissionTuple.new(account: false, build: false, characters: false, guilds: false, inventories: false, progression: false, pvp: false, tradingpost: false, unlocks: false, wallet: false)
    NO_TOKEN = TokenInfo.new("", "", NO_PERMS)

    def token_info
      return TokenInfo.new of String unless @headers["Authorization"]?
      TokenInfo.from_json(get("/tokeninfo"))
    end

    def permissions
      token_info.permissions
    end

    def permission?(sym : Symbol)
      token_info.permissions[sym]?
    end
  end
end
