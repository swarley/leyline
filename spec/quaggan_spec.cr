require "./spec_helper"
require "webmock"

describe "Leyline.quaggans" do
  it "returns a list of all quaggan ids when no id is provided" do
    WebMock.stub(:get, Leyline::BASE_URL + "/quaggans")
      .to_return(body: %(["404", "Beach", "Scifi", "Pink"]))

    Leyline.quaggans.should eq ["404", "Beach", "Scifi", "Pink"]
  end

  it "returns a hash of quaggans, {id => url}, when a list is provided" do
    WebMock.stub(:get, Leyline::BASE_URL + "/quaggans")
      .to_return(body: %([{"id": "scifi", "url": "scifi-url"}, {"id": "404", "url": "404-url"}]))

    Leyline.quaggans("all").should eq ({"scifi" => "scifi-url", "404" => "404-url"})
  end
end
