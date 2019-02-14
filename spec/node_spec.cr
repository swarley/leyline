require "./spec_helper"

describe "Leyline.nodes" do
  client = Leyline::Client.new

  it "returns a list of nodes when no arguments are given" do
    WebMock.stub(:get, Leyline::BASE_URL + "/nodes")
      .to_return(body: %(["basic_cloth_rack", "basic_harvesting_nodes", "basic_leather_rack"]))
    client.nodes.should eq (["basic_cloth_rack", "basic_harvesting_nodes", "basic_leather_rack"])
  end

  it "caches the list of nodes on the first call" do
    # No stubbing the endpoint here.
    client.nodes.should eq (["basic_cloth_rack", "basic_harvesting_nodes", "basic_leather_rack"])
  end

  it "returns a bool value representing the precense of the given id in the node list" do
    client.node?("basic_cloth_rack").should eq true
    client.node?("not_a_valid_node").should eq false
  end

end
