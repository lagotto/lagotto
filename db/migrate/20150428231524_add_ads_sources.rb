class AddAdsSources < ActiveRecord::Migration
  def up
    cited = Group.where(name: 'cited').first_or_create(title: 'Cited')

    if (ActiveRecord::Base.connection.table_exists? 'agents')
      ads = Agent.where(name: 'ads').first_or_create(
        :type => "Ads",
        :title => "ADS",
        :description => "Astrophysics Data System.",
        :group_id => cited.id)
      ads_fulltext = Agent.where(name: 'ads_fulltext').first_or_create(
        :type => "AdsFulltext",
        :title => "ADS Fulltext",
        :description => "Astrophysics Data System Fulltext Search.",
        :group_id => cited.id)
    end
  end

  def down
    Source.where(name: "ads").destroy_all
    Source.where(name: "ads_fulltext").destroy_all
  end
end
