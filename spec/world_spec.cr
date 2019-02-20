require "./spec_helper"

describe "Leyline" do
  describe "Worlds" do
    client = Leyline::Client.new

    it "returns a World object based on it's ID" do
      WebMock.stub(:get, Leyline::BASE_URL + "/worlds?id=1004")
        .to_return(body: %({
        "id": 1004,
        "name": "Henge of Denravi",
        "population": "VeryHigh"
      }))
      client.world(1004).name.should eq "Henge of Denravi"
    end

    it "returns all worlds as a hash (String => World)" do
      WebMock.stub(:get, Leyline::BASE_URL + "/worlds")
        .to_return(body: %([
          1004,
          1005,
          1006
        ]))
      # This also tests the cache, because we should only be calling the worlds we haven't
      # cached. And 1004 (Henge of Denravi) was cached on the last spec
      WebMock.stub(:get, "https://api.guildwars2.com/v2/worlds?ids=1005%2C1006")
        .to_return(body: %(
          [
            {
              "id": 1005,
              "name": "Maguuma",
              "population": "Medium"
            },
            {
              "id": 1006,
              "name": "Sorrow's Furnace",
              "population": "Medium"
            }
          ]
        ))
      client.worlds["1005"].should eq Leyline::World.from_json(%({
        "id": 1005,
        "name": "Maguuma",
        "population": "Medium"
      }))
    end
  end
end
