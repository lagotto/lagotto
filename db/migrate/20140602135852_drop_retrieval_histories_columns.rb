class DropRetrievalHistoriesColumns < ActiveRecord::Migration
  def up
    remove_column :api_responses, :retrieval_history_id
    add_column :api_responses, :skipped, :boolean, :default => false

    remove_column :retrieval_statuses, :data_rev
    add_column :retrieval_statuses, :other, :text
  end

  def down
    add_column :api_responses, :retrieval_history_id, :integer
    remove_column :api_responses, :skipped

    add_column :retrieval_statuses, :data_rev, :string
    remove_column :retrieval_statuses, :other
  end
end
