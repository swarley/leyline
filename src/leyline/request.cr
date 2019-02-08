require "http"
require "json"
require "../leyline"
require "./exception"

module Leyline
  class Client

    # TODO: Handle paging @page_size = Leyline::DEFAULT_PAGE_SIZE
    def initialize(token : String? = nil, language : String? = nil)
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

      resp = HTTP::Client.get(Leyline::BASE_URL + endpoint + HTTP::Params.encode(params), @headers)

      case resp.status_code
      when 200..299
        return resp
      when 403
        raise Leyline::Exception.new("Invalid API Key", resp)
      when 404
        raise Leyline::Exception.new("Invalid API Endpoint", resp)
      when 405..499
        raise Leyline::Exception.new("Generic Client Error", resp)
      when 500..599
        raise Leyline::Exception.new("Server Error", resp)
      else
        raise Leyline::Exception.new("Unknown response code", resp)
      end
    end

    def get(endpoint, params = {} of String => String) : String
      request(endpoint, params).body
    end
  end
end
