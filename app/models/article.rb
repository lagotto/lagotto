require "doi"

class Article < ActiveRecord::Base

  has_many :retrieval_statuses, :dependent => :destroy
  has_many :sources, :through => :retrieval_statuses

  validates_format_of :doi, :with => DOI::FORMAT
  validates_uniqueness_of :doi

  scope :query, lambda { |query| where("doi like ?", "%#{query}%") }

  def citations_count
    retrieval_statuses.inject(0) { |sum, r| sum + r.event_count }
  end

  def cited_retrievals_count
    retrieval_statuses.select {|r| r.event_count > 0}.size
  end
end
