class RenameReportWriteLogsToFileWriteLogs < ActiveRecord::Migration
  def change
    rename_table :report_write_logs, :file_write_logs
    rename_column :file_write_logs, :report_type, :file_type
  end
end
