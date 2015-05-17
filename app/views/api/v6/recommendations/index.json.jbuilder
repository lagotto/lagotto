json.meta do
  json.status "ok"
  json.set! :"message-type", "similar_work-list"
  json.set! :"message-version", "6.0.0"
  json.total @recommendations.total_entries
  json.total_pages @recommendations.per_page > 0 ? @recommendations.total_pages : 1
  json.page @recommendations.total_entries > 0 ? @recommendations.current_page : 1
end

json.recommendations @recommendations do |recommendation|
  json.cache! ['v6', "recommendation", recommendation, params[:work_id], params[:source_id], params[:relation_type_id]], skip_digest: true do
    json.(recommendation.work, :id, :publisher_id)
    json.(recommendation, :work_id, :source_id, :relation_type_id)
    json.(recommendation.work, :title, :issued)
    json.set! :"container-title", recommendation.work.container_title
    json.(recommendation.work, :volume, :page, :issue, :DOI, :URL, :PMID, :PMCID, :arxiv, :scp, :wos, :ark, :events)
    json.(recommendation, :timestamp)
  end
end
