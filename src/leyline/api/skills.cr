require "../client"
require "json"

# TODO:
#   There's a few things that need to be changed to make this
#   better than a simple abstraction.
#
#   Anything that refers to a skill id should instead have a Skill object
#   that doesn't have it's data prefetched.
#
#   Add the ability to lazily load data
#

module Leyline
  class Skill
    module FactConverter
      def self.from_json(parser : JSON::PullParser)
        objects = [] of (AttributeAdjust | Buff | ComboField | ComboFinisher | Damage | Distance | Duration | Heal | HealingAdjust | NoData | Number | Percent | PrefixedBuff | Radius | Range | Recharge | Time | Unblockable)
        parser.read_array do
          puts "reading new object"
          json = parser.read_raw
          case JSON.parse(json)["type"].as_s
          when "AttributeAdjust"
            objects << AttributeAdjust.from_json(json)
          when "Buff"
            objects << Buff.from_json(json)
          when "ComboField"
            objects << ComboField.from_json(json)
          when "ComboFinisher"
            objects << ComboFinisher.from_json(json)
          when "Damage"
            objects << Damage.from_json(json)
          when "Distance"
            objects << Distance.from_json(json)
          when "Duration"
            objects << Duration.from_json(json)
          when "Heal"
            objects << Heal.from_json(json)
          when "HealingAdjust"
            objects << HealingAdjust.from_json(json)
          when "NoData"
            objects << NoData.from_json(json)
          when "Number"
            objects << Number.from_json(json)
          when "Percent"
            objects << Percent.from_json(json)
          when "PrefixedBuff"
            objects << PrefixedBuff.from_json(json)
          when "Radius"
            objects << Radius.from_json(json)
          when "Range"
            objects << Range.from_json(json)
          when "Recharge"
            objects << Recharge.from_json(json)
          when "Time"
            objects << Recharge.from_json(json)
          when "Unblockable"
            objects << Unblockable.from_json(json)
          else
          end
        end

        return objects
      end
    end

    class Fact
      include JSON::Serializable

      getter icon : String
      getter text : String
      getter type : String
      getter requires_trait : Int32?
      getter overrides : Int32?
    end

    class AttributeAdjust < Fact
      include JSON::Serializable

      getter target : String
      getter value : Int32
    end

    class Buff < Fact
      getter apply_count : Int32?
      # Duration in seconds
      getter duration : Int32?
      getter status : String
      getter description : String?
    end

    class ComboField < Fact
      #  One of: Air, Dark, Fire, Ice, Light, Lightning, Poison, Smoke, Ethereal, Water
      getter field_type : String
    end

    class ComboFinisher < Fact
      getter finisher_type : String
      getter percent : Int32
    end

    class Damage < Fact
      getter hit_count : Int32
      getter dmg_multiplier : Int32
    end

    class Distance < Fact
      getter distance : Int32
    end

    class Duration < Fact
      getter duration : Int32
    end

    class Heal < Fact
      getter hit_count : Int32
    end

    class HealingAdjust < Fact
      getter hit_count : Int32
    end

    class NoData < Fact
    end

    class Number < Fact
      getter value : Int32
    end

    class Percent < Fact
      getter percent : Int32
    end

    class Prefix
      include JSON::Serializable

      getter text : String
      getter icon : String
      getter status : String
      getter description : String
      getter requires_trait : Int32?
      getter overrides : Int32?
    end

    class PrefixedBuff < Buff
      getter prefix : Prefix
    end

    class Radius < Distance
    end

    class Range
      include JSON::Serializable

      getter text : String
      getter type : String
      getter value : Int32
      getter requires_trait : Int32?
      getter overrides : Int32?
    end

    class Recharge
      include JSON::Serializable

      getter text : String
      getter type : String
      getter value : Int32
      getter requires_trait : Int32?
      getter overrides : Int32?
    end

    class Time < Fact
      getter duration : Int32
    end

    class Unblockable
      include JSON::Serializable

      getter text : String
      getter type : String
      getter value : Bool
      getter requires_trait : Int32?
      getter overrides : Int32?
    end
  end
end

module Leyline
  class Skill
    include JSON::Serializable

    getter id : Int32
    getter name : String
    getter description : String?
    getter icon : String
    getter chat_link : String
    getter type : String?
    getter weapon_type : String?
    getter professions : Array(String)
    getter slot : String?
    @[JSON::Field(converter: Leyline::Skill::FactConverter)]
    getter facts : Array(AttributeAdjust | Buff | ComboField | ComboFinisher | Damage | Distance | Duration | Heal | HealingAdjust | NoData | Number | Percent | PrefixedBuff | Radius | Range | Recharge | Time | Unblockable)
    getter traited_facts : Array(AttributeAdjust | Buff | ComboField | ComboFinisher | Damage | Distance | Duration | Heal | HealingAdjust | NoData | Number | Percent | PrefixedBuff | Radius | Range | Recharge | Time | Unblockable)?
    getter categories : Array(String)?
    getter attunement : String?
    getter cost : Int32?
    getter dual_wield : String?
    getter flip_skill : Int32?
    getter initiative : Int32?
    getter next_chain : Int32?
    getter prev_chain : Int32?
    getter transform_skills : Array(Int32)?
    getter bundle_skills : Array(Int32)?
    getter toolbelt_skill : Int32?

    # TODO: Need a separate helper for loading all the skills as an array. Implementing paging before this
    # is likely necessary
    def self.get(id : Int32, client = Leyline::Client.new)
      Leyline::Skill.from_json(client.get("/skills", {"id" => id.to_s}))
    end
  end
end
