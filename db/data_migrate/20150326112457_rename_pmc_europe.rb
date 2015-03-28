class RenamePmcEurope < ActiveRecord::Migration
  def up
    europe_pmc = Source.where(name: "pmceurope").first
    europe_pmc.update_attributes(name: "europe_pmc", type: "EuropePmc") if europe_pmc

    europe_pmc_data = Source.where(name: "pmceuropedata").first
    europe_pmc_data.update_attributes(name: "europe_pmc_data", type: "EuropePmcData") if europe_pmc_data
  end

  def down
    europe_pmc = Source.where(name: "europe_pmc").first
    europe_pmc.update_attributes(name: "pmceurope", type: "PmcEurope") if europe_pmc

    europe_pmc_data = Source.where(name: "europe_pmc_data").first
    europe_pmc_data.update_attributes(name: "pmceuropedata", type: "PmcEuropeData") if europe_pmc_data
  end
end
