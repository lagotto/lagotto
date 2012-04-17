require 'source_helper'

class RetrievalStatus < ActiveRecord::Base
  include SourceHelper

  belongs_to :article
  belongs_to :source
  has_many :retrieval_histories, :dependent => :destroy

  def get_retrieval_data
    source = Source.find(source_id)
    article = Article.find(article_id)
    begin
      data = get_alm_data("#{source.name}:#{CGI.escape(article.doi)}")
    rescue => e
      Rails.logger.error "Failed to get data for #{source.name}:#{article.doi}.  #{e.message}"
    end
  end

end
