require "cossack"

module Leyline
  class Exception < ::Exception
    getter response

    def initialize(message : String, @response : Cossack::Client::Response)
      super message
    end
  end
end
