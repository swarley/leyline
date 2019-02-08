require "cossack"
require "http/params"
require "json"
require "../leyline"
require "./exception"

module Leyline
  class Client

    # TODO: Handle paging @page_size = Leyline::DEFAULT_PAGE_SIZE
    def initialize(token = "", language = "en")
      unless token.empty?
        token = "Bearer #{token}" unless token =~ /^Bearer\s/
      end

      @client = Cossack::Client.new(Leyline::BASE_URL) do |client|
        client.use Cossack::RedirectionMiddleware

        client.headers["Authorization"] = token unless token.empty?
        client.headers["Accept-Language"] = language
      end
    end

    # TODO: Handle paging
    def request(endpoint, params = {} of String => String) : Cossack::Client::Response
      endpoint = "/#{endpoint}" unless endpoint[0] == '/'

      resp = @client.get(endpoint + HTTP::Params.encode(params))

      case resp.status
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
