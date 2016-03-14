class AddEventsUrl < ActiveRecord::Migration
  def change
    add_column :relations, :provenance_url, :text, limit: 65535
  end
end
