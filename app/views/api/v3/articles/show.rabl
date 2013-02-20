object ArticleDecorator.decorate(@article)
cache ArticleDecorator.decorate(@article)

attributes :doi, :title, :url, :mendeley, :pmid, :pmcid, :publication_date, :update_date

unless params[:info] == "summary"
  child :retrieval_statuses => :sources do
    attributes :name, :events_url, :metrics, :update_date
    
    attributes :events if ["detail","event"].include?(params[:info])
    attributes :histories if ["detail","history"].include?(params[:info])
  end
end