class RenameAbstractAndRefreshedAt < ActiveRecord::Migration
  class Article < ActiveRecord::Base; end
  class Citation < ActiveRecord::Base; end

  def self.up
    rename_column "articles", "refreshed_at", "retrieved_at"
    rename_column "citations", "abstract", "details"
  end

  def self.down
    rename_column "articles", "retrieved_at", "refreshed_at"
    rename_column "citations", "details", "abstract"
  end
end
