class AddFailedAtToDataExports < ActiveRecord::Migration
  def change
    add_column :data_exports, :failed_at, :datetime
  end
end
