require "http"
require "json"
require "../leyline"

module Leyline
  class Request
    @response : HTTP::Client::Response
    @token : String?
    @language : String?
    getter response

    def initialize(@url : String, @token = nil, @language = nil, @page_size = Leyline::DEFAULT_PAGE_SIZE, @args = {} of String => String)
      @url = Leyline::BASE_URL + @url
      @response = HTTP::Client::Response.new(418)
      @token = "Bearer #{@token}" unless @token =~ /^Bearer\s/
    end

    def get(page = -1, params = {} of String => String)
      headers = HTTP::Headers.new
      if @token
        headers.add("Authorization", @token.as(String))
      end

      headers.add("Accept-Language", @language.as(String)) if @language

      url = @url
      if page >= 0
        headers.add("X-Page-Size", @page_size.to_s)
        params["page"] = page.to_s
      end

      @response = HTTP::Client.get("#{url}?#{HTTP::Params.encode(params)}", headers)

      return @response.body
    end

    def get_any(page = -1, params = {} of String => String)
      get(page, params)
      JSON.parse(@response.body)
    end
  end
end
