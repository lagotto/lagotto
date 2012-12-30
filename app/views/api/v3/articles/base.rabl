attributes :doi, :title, :url, :mendeley, :mendeley_url
attribute :pub_med => :pmid
attribute :pub_med_central => :pmcid

node(:publication_date) { |article| article.published_on.nil? ? nil : article.published_on.to_time.utc.iso8601 }

if params[:source]
  source_ids = Source.where("lower(name) in (?)", params[:source].split(",")).order("display_name").pluck(:id)
else
  source_ids = Source.order("display_name").pluck(:id)
end

unless params[:info] == "summary"
  node :sources do |article|
    if params[:source]
      source_ids = Source.where("lower(name) in (?)", params[:source].split(",")).order("display_name").pluck(:id)
      retrieval_statuses = article.retrieval_statuses.by_source(source_ids)
    else
      retrieval_statuses = article.retrieval_statuses
    end
    
    retrieval_statuses.map do |retrieval_status|
      partial 'api/v3/retrieval_statuses/base', object: retrieval_status
    end
  end
end