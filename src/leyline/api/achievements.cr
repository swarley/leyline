require "../client"
require "../cache"
require "json"

module Leyline
  module Converters
    module AchievementFlagsConverter
      def self.from_json(parser : JSON::PullParser)
        flags = Leyline::Achievement::Flags.new 0
        parser.read_array do
          flags |= Leyline::Achievement::Flags.parse(parser.read_string)
        end
        flags
      end
    end
  end

  struct Achievement
    # TODO: This helps in saving memory, but it's less intuitive to compare the enum
    # than to have them stored as strings or symbols. Change?
    enum Type
      Default
      ItemSet

      def self.new(parser : JSON::PullParser)
        Type.parse(parser.read_string)
      end
    end

    @[Flags]
    enum Flags
      PvP
      CategoryDisplay
      MoveToTop
      IgnoreNearlyComplete
      Repeatable
      Hidden
      RequiresUnlock
      RepairOnLogin
      Daily
      Weekly
      Monthly
      Permanent
    end

    module Reward
      include JSON::Serializable
      getter type : String
    end

    struct CoinReward
      include Reward
      getter count : Int32
    end

    struct ItemReward
      include Reward
      getter id : Int32
      getter count : Int32
    end

    struct MasteryReward
      include Reward
      getter id : Int32
      getter region : String # This could be converted to an enum at some point
    end

    struct TitleReward
      include Reward
      getter id : Int32
    end

    alias RewardType = CoinReward | ItemReward | MasteryReward | TitleReward

    struct TextBit
      include JSON::Serializable
      getter type : String
      getter text : String
    end

    # Encompasses Item, Minipet, and Skin types
    struct ItemBit
      include JSON::Serializable
      getter type : String
      getter id : Int32
    end

    include JSON::Serializable

    getter id : Int32
    getter icon : String?
    getter name : String
    getter description : String
    getter requirement : String
    getter locked_text : String
    getter type : Type

    @[JSON::Field(converter: Leyline::Converters::AchievementFlagsConverter)]
    getter flags : Flags

    getter tiers : Array(NamedTuple(count: Int32, points: Int32))
    getter prerequisites : Array(Int32)?
    getter rewards : Array(RewardType)?

    # Honestly I have no idea what this is used for. Docs refer to it as
    # a bitmask but I have no idea where the numbers for said mask are coming
    # from.
    getter bits : Array(TextBit | ItemBit)?

    getter point_cap : Int32?

    def default?
      @type == Type::Default
    end

  end
end
