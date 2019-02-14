require "../client"
require "../cache"
require "json"

module Leyline
  class Client
    def quaggans(list = "all") : Hash(String, String)
      if list == "all"
        return @quaggan_cache[@id_cache["/quaggans"]] # .each do |quaggan|
        #   quaggan_hash[quaggan] = @quaggan_cache[quaggan]
        # end
        # return quaggan_hash
      end

      return quaggans(list.split(','))
    end

    def quaggans(list : Array(String))
      return @quaggan_cache[list]
    end
  end
end
