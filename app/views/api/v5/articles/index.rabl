object false
cache ['v5', @articles]

node(:total) { |m| @articles.total_entries }
node(:total_pages) { |m| (@articles.total_entries.to_f / @articles.per_page).ceil }
node(:page) { |m| @articles.total_entries > 0 ? @articles.current_page : 0 }
node(:error) { nil }

child @articles => :data do
  attributes :doi, :title, :issued, :canonical_url, :pmid, :pmcid, :mendeley_uuid, :viewed, :saved, :discussed, :cited, :update_date

  unless params[:info] == "summary"
    child :filtered_retrieval_statuses => :sources do
      attributes :name, :display_name, :group_name, :events_url, :by_day, :by_month, :by_year
      attributes :new_metrics => :metrics
      attributes :update_date

      attributes :events, :events_csl if params[:info] == "detail"
    end
  end
end
