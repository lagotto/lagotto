class RenamePmcEurope < ActiveRecord::Migration
  def up
    europe_pmc = Source.where(type: "PmcEurope").update_attributes(name: "europe_pmc", type: "EuropePmc")
    europe_pmc_data = Source.where(type: "PmcEuropeData").update_attributes(name: "europe_pmc_data", type: "EuropePmcData") if europe_pmc_data
  end

  def down
    europe_pmc = Source.where(type: "EuropePmc").update_attributes(name: "pmceurope", type: "PmcEurope") if europe_pmc
    europe_pmc_data = Source.where(type: "EuropePmcData").update_attributes(name: "pmceuropedata", type: "PmcEuropeData") if europe_pmc_data
  end
end
