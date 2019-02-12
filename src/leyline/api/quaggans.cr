require "../client"
require "../cache"
require "json"

module Leyline
  class Client

    def quaggans(list = "all") : Hash(String, String)
      quaggan_hash = {} of String => String
      if list == "all"
        @id_cache["/quaggans"].each do |quaggan|
          quaggan_hash[quaggan] = @quaggan_cache[quaggan]
        end
        return quaggan_hash
      end

      return quaggans(list.split(','))


      # HOL UP BRAINBLAST USE THE ENDPOINTS WITHOUT ARGS TO SEE IF WE HAVE THAT MANY ELEMENTS
      # IF WE DON'T THEN WE AREN'T FULLY CACHED. BUT THIS IS MORE OF A THING THAT THE CACHE WOULD HAVE TO USE SOME
      # METRIC TO ENSURE SO I'LL HAVE TO FIGURE SOMETHING OUT ABOUT THAT.
      #
      # the cache currently doesn't have a good way of knowing if all indexes are cached.
      # Potentially I could have it set a flag on the first "all" request so that it can
      # pull entirely from the cache

      # quaggans = Array(Hash(String, String)).from_json(get("/quaggans"))

      # quaggan_hash = {} of String => String
      # quaggans.each { |quaggan| quaggan_hash[quaggan["id"]] = quaggan["url"] }
      # return quaggan_hash
    end

    def quaggans(list : Array(String))
      quaggan_hash = {} of String => String

      list.each do |quaggan|
        quaggan_hash[quaggan] = @quaggan_cache[quaggan]
      end

      return quaggan_hash
    end
  end
end
