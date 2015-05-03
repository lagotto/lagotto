class RenamePmcEurope < ActiveRecord::Migration
  def up
    europe_pmc = Source.where(type: "PmcEurope").update_all(name: "europe_pmc", type: "EuropePmc")
    europe_pmc_data = Source.where(type: "PmcEuropeData").update_all(name: "europe_pmc_data", type: "EuropePmcData") if europe_pmc_data
  end

  def down
    europe_pmc = Source.where(type: "EuropePmc").update_all(name: "pmceurope", type: "PmcEurope") if europe_pmc
    europe_pmc_data = Source.where(type: "EuropePmcData").update_all(name: "pmceuropedata", type: "PmcEuropeData") if europe_pmc_data
  end
end
