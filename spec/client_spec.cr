require "./spec_helper"

describe Leyline::Client do
  describe "#initialize" do
    it "sets provided headers when initialized" do
      korean_client = Leyline::Client.new(language: "ko")
      korean_client.headers["Accept-Language"].should eq "ko"

      authenticated_client = Leyline::Client.new(token: "DEAD-BEEF")
      authenticated_client.headers["Authorization"].should eq "Bearer DEAD-BEEF"

      auth_kor_client = Leyline::Client.new(token: "BEEF-BABE", language: "ko")
      auth_kor_client.headers["Authorization"].should eq "Bearer BEEF-BABE"
      auth_kor_client.headers["Accept-Language"].should eq "ko"
    end

    it "formats the token for request headers when needed" do
      auth_client = Leyline::Client.new(token: "DEAD-BEEF")
      auth_client.headers["Authorization"].should eq "Bearer DEAD-BEEF"

      formatted_auth_client = Leyline::Client.new(token: "Bearer DEAD-BEEF")
      formatted_auth_client.headers["Authorization"].should eq "Bearer DEAD-BEEF"
    end
  end

  describe "#request" do
    it "returns a response for status code 200..299" do
      WebMock.stub(:get, Leyline::BASE_URL + "/quaggans")
        .to_return(status: 200, body: %[{"text": "success"}])

      Leyline::Client.new.request("/quaggans").body.should eq %[{"text": "success"}]
    end

    it "raises exceptions for 403 status codes" do
      WebMock.stub(:get, Leyline::BASE_URL + "/quaggans")
        .to_return(status: 403, body: %[{"text": "endpoint requires authentication"}])

      expect_raises(Leyline::Exception, "Token Error accessing '/quaggans': endpoint requires authentication") do
        Leyline::Client.new.request("/quaggans")
      end
    end

    it "raises exceptions for 404 status codes" do
      WebMock.stub(:get, Leyline::BASE_URL + "/quaggans")
        .to_return(status: 404, body: %[{"error":"not found"}])

      expect_raises(Leyline::Exception, "Invalid API Endpoint '/quaggans'") do
        Leyline::Client.new.request("/quaggans")
      end
    end

    it "raises an exception for unknown status codes" do
      WebMock.stub(:get, Leyline::BASE_URL + "/quaggans")
        .to_return(status: 999)

      expect_raises(Leyline::Exception, "Unknown response code: 999") do
        Leyline::Client.new.request("/quaggans")
      end
    end
  end
end
