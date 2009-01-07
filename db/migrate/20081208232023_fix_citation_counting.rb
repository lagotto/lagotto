class FixCitationCounting < ActiveRecord::Migration
  class Article < ActiveRecord::Base; end
  class Retrieval < ActiveRecord::Base;
    has_many :citations
  end

  def self.up
    remove_column "articles", "citations_count"
    add_column "retrievals", "citations_count", :integer, :default => 0
    add_column "retrievals", "other_citations_count", :integer, :default => 0

    Retrieval.reset_column_information
    Retrieval.all.each do |r|
      Retrieval.update_counters r.id, :citations_count => r.citations.length
    end
  end

  def self.down
    add_column "articles", "citations_count", :integer, :default => 0
    remove_column "retrievals", "citations_count"
    remove_column "retrievals", "other_citations_count"
  end
end
