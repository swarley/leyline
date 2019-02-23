require "../client"
require "../cache"

module Leyline
  struct Title
    include JSON::Serializable

    getter id : Int32
    getter name : String
    getter achievement : Int32
    getter achievements : Array(Int32)
  end

  class Cache
    # `#titles`, `#cache_title`, `#cache_titles`, `#title`
    generate_simple_cache(Title, Int32)
  end

  class Client
    # TODO: need Achivement
  end
end
