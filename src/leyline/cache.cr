module Leyline
  module IntToStrConverter
    def self.from_json(parser : JSON::PullParser)
      (parser.kind == :int) ? parser.read_raw : parser.read_string
    end
  end

  class Cache
    macro generate_simple_cache(type, index_type)
      @{{type.id.downcase}}s = {} of {{index_type.id}} => Tuple(Time, {{type.id}})
      getter {{type.id.downcase}}s

      def {{type.id.downcase}}(id : {{index_type.id}}) : {{type.id}} | Nil
        if element = @{{type.id.downcase}}s[id]?
          time, object = element
          return nil if Time.now - time > 1.hour
          object
        end
      end

      def {{type.id.downcase}}(ids : Array({{index_type.id}})) : Array({{type.id}})
        # Don't return out of date ids
        @{{type.id.downcase}}s.reject { |q| Time.now - q[0] > 1.hour }
      end

      def cache_{{type.id.downcase}}({{type.id.downcase}} : {{type.id}}, time = Time.now)
        @{{type.id.downcase}}s[{{type.id.downcase}}.id] = {time, {{type.id.downcase}}}
      end

      def cache_{{type.id.downcase}}s({{type.id.downcase}}s : Array({{type.id}}))
        time = Time.now
        {{type.id.downcase}}s.each { |q| cache_{{type.id.downcase}}(q, time) }
      end
    end
  end
end
