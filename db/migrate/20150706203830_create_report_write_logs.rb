class CreateReportWriteLogs < ActiveRecord::Migration
  def change
    create_table :report_write_logs do |t|
      t.string :filepath
      t.string :report_type

      t.timestamps
    end
  end
end
