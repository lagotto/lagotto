object false
cache ['v5', @articles]

node(:total) { |m| @articles.total_entries }
node(:total_pages) { |m| (@articles.total_entries.to_f / @articles.per_page).ceil }
node(:page) { |m| @articles.total_entries > 0 ? @articles.current_page : 0 }
node(:error) { nil }

node :data do { @articles }
  attributes :doi, :title, :canonical_url, :mendeley_uuid, :pmid, :pmcid, :issued, :viewed, :saved, :discussed, :cited, :update_date

  unless params[:info] == "summary"
    child :filtered_retrieval_statuses => :sources do |rs|
      cache ['v5', rs]
      attributes :name, :display_name, :group_name, :events_url, :by_day, :by_month, :by_year, :update_date
      attributes :new_metrics => :metrics

      attributes :events, :events_csl if params[:info] == "detail"
    end
  end
end
