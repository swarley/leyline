require "../cache"
require "json"

module Leyline
  module PermissionConverter
    def self.from_json(parser : JSON::PullParser)
      perms = TokenInfo::Permissions.new(0)
      parser.read_array do
        perms |= TokenInfo::Permissions.parse(parser.read_string)
      end
      perms
    end
  end

  struct TokenInfo
    @[Flags]
    enum Permissions
      Account
      Builds
      Characters
      Guilds
      Inventories
      Progression
      PvP
      TradingPost
      Unlocks
      Wallet
    end

    include JSON::Serializable

    getter id : String
    getter name : String
    @[JSON::Field(converter: Leyline::PermissionConverter)]
    getter permissions : Permissions

    def initialize(@id = "", @name = "", @permissions = Permissions.new(0))
    end

    def permission?(perm : Permissions)
      @permissions.includes? perm
    end

    def permission?(perm : Int32)
      permission? Permission.from_value(perm)
    end

    def permission?(perm_name : String)
      permission? Permissions.parse(perm_name)
    end
  end

  class Client
    # TODO: The token should be stored in some way and force updated on token change.
    # Considering I'm not sure if changing permissions on tokens that have already
    # been generated is actually supported. I couldn't figure out a way to do
    # it on the gw2 website.

    def token_info
      return TokenInfo.new unless @headers["Authorization"]?
      TokenInfo.from_json(get("/tokeninfo"))
    end

    def permission?(perm : TokenInfo::Permissions)
      token_info.permission? perm
    end

    def permission?(i : Int32)
      token_info.permission? i
    end

    def permission?(str : String)
      token_info.permission? str
    end
  end
end
