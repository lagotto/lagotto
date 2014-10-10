class Publisher < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  has_many :users, primary_key: :crossref_id
  has_many :articles, primary_key: :crossref_id
  has_many :publisher_options, primary_key: :crossref_id, :dependent => :destroy
  has_many :sources, :through => :publisher_options

  serialize :prefixes
  serialize :other_names

  validates :name, :presence => true
  validates :crossref_id, :presence => true, :uniqueness => true

  def to_param  # overridden, use crossref_id instead of id
    crossref_id
  end

  def article_count
    Rails.cache.fetch("publisher/#{crossref_id}/article_count/#{update_date}",
                      articles.size).to_i
  end

  def update_date
    updated_at.utc.iso8601
  end
end
