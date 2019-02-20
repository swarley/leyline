require "./spec_helper"

describe "Leyline.quaggans" do
  client = Leyline::Client.new

  # Needs to be changed to verify that it requests all by default
  # it "returns a list of all quaggan ids when no id is provided" do
  #   WebMock.stub(:get, Leyline::BASE_URL + "/quaggans")
  #     .to_return(body: %(["404", "Beach", "Scifi", "Pink"]))
  #   client.quaggans.should eq ["404", "Beach", "Scifi", "Pink"]
  # end

  it "returns a hash of all quaggans, {id => url}, when no arguments are given" do
    WebMock.stub(:get, Leyline::BASE_URL + "/quaggans")
      .to_return(body: %(["scifi", "404"]))
    WebMock.stub(:get, Leyline::BASE_URL + "/quaggans?ids=all")
      .to_return(body: %([{"id": "scifi", "url": "scifi-url"}, {"id": "404", "url": "404-url"}]))
    WebMock.stub(:get, Leyline::BASE_URL + "/quaggans?ids=scifi,404")
      .to_return(body: %([{"id": "scifi", "url": "scifi-url"}, {"id": "404", "url": "404-url"}]))

    client.quaggans.should eq ({"scifi" => "scifi-url", "404" => "404-url"})
  end

  it "returns a hash of named quaggans when a list of ids are given" do
    WebMock.stub(:get, Leyline::BASE_URL + "/quaggans")
      .to_return(body: %(["scifi", "404", "never-reached", "nor-is-this"]))
    WebMock.stub(:get, Leyline::BASE_URL + "/quaggans?ids=all")
      .to_return(body: %([{"id": "scifi", "url": "scifi-url"}, {"id": "404", "url": "404-url"}]))
    WebMock.stub(:get, Leyline::BASE_URL + "/quaggans?ids=scifi,404")
      .to_return(body: %([{"id": "scifi", "url": "scifi-url"}, {"id": "404", "url": "404-url"}]))

    client.quaggans(["scifi", "404"]).should eq ({"scifi" => "scifi-url", "404" => "404-url"})
  end

  it "returns the url of a single quaggan when passed its id" do
    # WebMock.stub(:get, Leyline::BASE_URL + "/quaggans")
    #  .to_return(body: %(["scifi", "404", "never-reached", "nor-is-this"]))
    # WebMock.stub(:get, Leyline::BASE_URL + "/quaggans?ids=all")
    #  .to_return(body: %([{"id": "scifi", "url": "scifi-url"}, {"id": "404", "url": "404-url"}]))
    # WebMock.stub(:get, Leyline::BASE_URL + "/quaggans?ids=scifi,404")
    #  .to_return(body: %([{"id": "scifi", "url": "scifi-url"}, {"id": "404", "url": "404-url"}]))

    client.quaggan("scifi").should eq "scifi-url"
  end
end
