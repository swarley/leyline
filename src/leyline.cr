require "./leyline/*"
require "./leyline/api/quaggans"
require "./leyline/api/nodes"
require "./leyline/api/tokeninfo"

module Leyline
  BASE_URL = "https://api.guildwars2.com/v2"

  DEFAULT_PAGE_SIZE =  50
  MAX_PAGE_SIZE     = 200

  DEFAULT_LANGUAGE = "en"
end
