require "./spec_helper"

describe "Leyline" do
  describe "Achievement" do
    it "loads a valid json response properly" do
      ach = Leyline::Achievement.from_json(%(
        {
          "id": 1840,
          "name": "Daily Completionist",
          "description": "",
          "requirement": "Complete any  PvE, WvW, or PvP Daily Achievements.",
          "locked_text": "",
          "type": "Default",
          "flags": [
            "Pvp",
            "CategoryDisplay"
          ],
          "tiers": [
            {
              "count": 3,
              "points": 10
            }
          ],
          "rewards": [
            {
              "type": "Item",
              "id": 70047,
              "count": 1
            },
            {
              "type": "Coins",
              "count": 20000
            }
          ]
        }
      ))

      ach.id.should eq 1840
      ach.flags.should eq Leyline::Achievement::Flags.flags(PvP, CategoryDisplay)
      ach.default?.should eq true
      ach.tiers.should eq [{count: 3, points: 10}]

    end
  end

end
