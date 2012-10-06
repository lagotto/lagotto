unless @article.nil?
  object @article

  attributes :doi, :title, :url, :mendeley
  attribute :pub_med => :pmid
  attribute :pub_med_central => :pmcid

  node(:publication_date) { |article| article.published_on.nil? ? nil : article.published_on.to_time }
else
  object false
  
  node(:error) { "Article not found." }
end