require 'bolognese'

class Work < ActiveRecord::Base
  # include helper module for query caching
  include Cacheable

  # utility methods for DOI metadata
  include Bolognese::Utils
  include Bolognese::DoiUtils

  # store blank values as nil
  nilify_blanks

  has_many :events, inverse_of: :work

  validates :pid, :provider_id, presence: true
  before_validation :normalize_pid, :set_provider

  scope :indexed, -> { where("works.indexed = ?", true) }

  def self.per_page
    1000
  end

  def to_param  # overridden, use pid instead of id
    pid
  end

  def doi
    validate_doi(pid)
  end

  private

  # from bolognese gem
  # normalize DOI to lowercase and use of https://doi.org
  # clean up URLs using Postrank gem (remove query parameters, etc.)
  def normalize_pid
    self.pid = normalize_id(pid)
  end

  def set_provider
    return if provider_id.present?

    self.provider_id = find_from_format_by_id(pid)
  end
end
