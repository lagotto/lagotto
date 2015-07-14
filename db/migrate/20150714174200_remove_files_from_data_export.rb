class RemoveFilesFromDataExport < ActiveRecord::Migration
  class DataExport < ActiveRecord::Base
    self.inheritance_column = :_type_disabled

    serialize :data, Hash
    serialize :files, Array
  end

  def up
    DataExport.find_in_batches do |exports|
      exports.each do |export|
        files = export.files
        export.data[:files] = files
        export.save!
      end
    end

    remove_column :data_exports, :files
  end

  def down
    add_column :data_exports, :files, :text

    DataExport.find_in_batches do |exports|
      exports.each do |export|
        files = export.data[:files]
        export.files = files
        export.save!
      end
    end
  end
end
