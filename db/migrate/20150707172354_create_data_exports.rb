class CreateDataExports < ActiveRecord::Migration
  def change
    create_table :data_exports do |t|
      t.integer :size_in_kb
      t.string :url, :type, :state
      t.datetime :started_exporting_at, :finished_exporting_at
      t.text :data, :files

      t.timestamps
    end
  end
end
