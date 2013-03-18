class ArticleDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates_association :retrieval_statuses
  
  def publication_date
    published_on.nil? ? nil : published_on.to_time.utc.iso8601
  end
  
  def update_date
    updated_at.utc.iso8601
  end
  
  def pmid
    pub_med
  end
  
  def pmcid
    pub_med_central
  end

  def cache_key
    { :article_id => id, 
      :timestamp => updated_at.to_s(:number), 
      :source => context[:source],
      :info => context[:info],
      :days => context[:days],
      :months => context[:months],
      :year => context[:year] }
  end
end
