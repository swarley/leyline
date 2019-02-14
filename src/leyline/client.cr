require "http"
require "json"
require "../leyline"
require "./exception"
require "./cache"
require "./api/quaggans"

module Leyline
  class Client

    property headers

    # TODO: Handle paging @page_size = Leyline::DEFAULT_PAGE_SIZE
    def initialize(token : String? = nil, language : String? = nil)
      @cache = Leyline::Cache.new

      @headers = HTTP::Headers.new

      unless token.nil?
        token = "Bearer #{token}" unless token =~ /^Bearer\s/
        @headers.add("Authorization", token) unless token.nil?
      end

      @headers.add("Accept-Language", language) unless language.nil?
    end

    # TODO: Handle paging
    def request(endpoint, params = {} of String => String) : HTTP::Client::Response
      endpoint = "/#{endpoint}" unless endpoint[0] == '/'

      url = Leyline::BASE_URL + endpoint
      url += "?" + HTTP::Params.encode(params) unless params.empty?
      resp = HTTP::Client.get(url, @headers)

      case resp.status_code
      when 200..299
        return resp
      when 403
        error_reason = JSON.parse(resp.body)
        raise Leyline::Exception.new("Token Error accessing '#{endpoint}': #{error_reason["text"]}", resp)
      when 404
        raise Leyline::Exception.new("Invalid API Endpoint '#{endpoint}'", resp)
      when 405..499
        raise Leyline::Exception.new("Client Error: #{resp.status_code}", resp)
      when 500..599
        raise Leyline::Exception.new("Server Error: #{resp.status_code}", resp)
      else
        raise Leyline::Exception.new("Unknown response code: #{resp.status_code}", resp)
      end
    end

    def get(endpoint, params = {} of String => String) : String
      request(endpoint, params).body
    end
  end
end
