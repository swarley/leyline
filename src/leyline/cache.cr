module Leyline
  module IntToStrConverter
    def self.from_json(parser : JSON::PullParser)
      (parser.kind == :int) ? parser.read_raw : parser.read_string
    end
  end

  class Cache
    # Stub
  end
end
