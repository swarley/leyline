require "./spec_helper"

ALL_PERMS_JSON = %({
  "id": "TEST-TOKEN-FOR-AUTHORIZATION",
  "name": "All Permissions Key",
  "permissions": [
    "tradingpost",
    "characters",
    "pvp",
    "progression",
    "wallet",
    "guilds",
    "builds",
    "account",
    "inventories",
    "unlocks"
  ]
})

SOME_PERMS_JSON = %({
  "id": "REDACTED-API-KEY",
  "name": "Some Perms Key",
  "permissions": [
    "tradingpost",
    "wallet",
    "inventories",
    "unlocks"
  ]
})

describe "Leyline" do
  describe "TokenInfo" do
    it "converts an array of permissions into an int for bitwise logic" do
      token_info = Leyline::TokenInfo.from_json(SOME_PERMS_JSON)
      token_info.permission?("account").should eq false
      token_info.permission?("wallet").should eq true
      token_info.permission?(Leyline::TokenInfo::Permissions::Inventories).should eq true
      token_info.permission?(Leyline::TokenInfo::Permissions::PvP).should eq false
    end
  end

  describe "Client" do
    no_auth_client = Leyline::Client.new
    client = Leyline::Client.new("TEST-TOKEN-FOR-AUTHORIZATION")

    it "returns an empty token if the client has no token set" do
      no_auth_client.token_info.should eq Leyline::TokenInfo.new
    end

    it "parses the token from the endpoint properly" do
      WebMock.stub(:get, "https://api.guildwars2.com/v2/tokeninfo")
        .with(headers: {"Authorization" => "Bearer TEST-TOKEN-FOR-AUTHORIZATION"})
        .to_return(body: ALL_PERMS_JSON)

      info = client.token_info
      info.name.should eq "All Permissions Key"
      info.id.should eq "TEST-TOKEN-FOR-AUTHORIZATION"
      info.permission?(
        Leyline::TokenInfo::Permissions.flags(Account, Builds, Characters, Guilds, Inventories, Progression, PvP, TradingPost, Unlocks, Wallet)
      ).should eq true
    end
  end
end
