class AllowBlankOrcid < ActiveRecord::Migration
  def up
    change_column :contributors, :orcid, :string, limit: 191, null: true
  end

  def down
    change_column :contributors, :orcid, :string, limit: 191, null: false
  end
end
