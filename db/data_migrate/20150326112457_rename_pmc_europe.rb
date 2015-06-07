class RenamePmcEurope < ActiveRecord::Migration
  def up
    europe_pmc = Agent.where(type: "PmcEurope").update_all(type: "EuropePmc")
    europe_pmc_data = Agent.where(type: "PmcEuropeData").update_all(type: "EuropePmcData")
  end

  def down
    europe_pmc = Agent.where(type: "EuropePmc").update_all(type: "PmcEurope")
    europe_pmc_data = Agent.where(type: "EuropePmcData").update_all(type: "PmcEuropeData")
  end
end
