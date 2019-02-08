require "../request"
require "json"

module Leyline
  class Quaggan
    JSON.mapping(id: String, url: String)
  end

  def self.quaggans(list = "", client = nil) : Array(String) | Hash(String, String)
    client = Leyline::Client.new()

    # With no arguments return a list with all quaggan ids
    return Array(String).from_json(client.get("/quaggans")) if list.empty?


    quaggans = Array(Hash(String, String)).from_json(client.get("/quaggans"))

    quaggan_hash = {} of String => String
    quaggans.each { |quaggan| quaggan_hash[quaggan["id"]] = quaggan["url"] }
    return quaggan_hash
  end

  def self.quaggans(list : Array(String))
    self.quaggans(list.join(','))
  end
end
