class RenamePmcEurope < ActiveRecord::Migration
  def up
    europe_pmc = Agent.where(type: "PmcEurope").update_all(type: "EuropePmc") if !!Agent rescue false
    europe_pmc_data = Agent.where(type: "PmcEuropeData").update_all(type: "EuropePmcData") if !!Agent rescue false
  end

  def down
    europe_pmc = Agent.where(type: "EuropePmc").update_all(type: "PmcEurope") if !!Agent rescue false
    europe_pmc_data = Agent.where(type: "EuropePmcData").update_all(type: "PmcEuropeData") if !!Agent rescue false
  end
end
