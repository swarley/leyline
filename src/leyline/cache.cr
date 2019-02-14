module Leyline
  module IntToStrConverter
    def self.from_json(parser : JSON::PullParser)
      if parser.kind == :int
        parser.read_raw
      else
        parser.read_string
      end
    end
  end

  class Cache
  end
end
