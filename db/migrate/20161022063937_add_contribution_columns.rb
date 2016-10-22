class AddContributionColumns < ActiveRecord::Migration
  def change
    add_column :contributions, :month_id, :integer
    add_column :contributions, :occurred_at, :datetime

    add_index "contributions", ["month_id"], name: "contributions_month_id_fk"
  end
end
