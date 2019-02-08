require "../request"
require "json"

module Leyline
  class Quaggan
    JSON.mapping(id: String, url: String)
  end

  def self.quaggans(list = "all")
    request = Leyline::Request.new("/quaggans")
    data = Array(Quaggan).from_json(request.get(params: {"ids" => list}))
    quaggan_hash = {} of String => String
    data.each { |quaggan| quaggan_hash[quaggan.id] = quaggan.url }
    return quaggan_hash
  end

  def self.quaggans(list : Array(String))
    self.quaggans(list.join(','))
  end
end

p Leyline.quaggans
