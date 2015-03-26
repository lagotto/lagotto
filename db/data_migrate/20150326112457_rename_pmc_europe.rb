class RenamePmcEurope < ActiveRecord::Migration
  def up
    europe_pmc = Source.where('pmceurope').first
    europe_pmc.update_attributes(name: "europe_pmc") if europe_pmc

    europe_pmc_data = Source.where('pmceuropedata').first
    europe_pmc_data.update_attributes(name: "europe_pmc_data") if europe_pmc_data
  end

  def down
    europe_pmc = Source.where('europe_pmc').first
    europe_pmc.update_attributes(name: "pmceurope") if europe_pmc

    europe_pmc_data = Source.where('europe_pmc_data').first
    europe_pmc_data.update_attributes(name: "pmceuropedata") if europe_pmc_data
  end
end
