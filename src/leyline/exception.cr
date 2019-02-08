module Leyline
  class Exception < ::Exception
    getter response

    def initialize(message : String, @response : HTTP::Client::Response)
      super message
    end
  end
end
