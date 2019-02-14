module Leyline
  module API
    module IntToStrConverter
      def self.to_json(parser : JSON::PullParser)
        int = parser.read_i
        return int.to_s
      end
    end
  end
end
