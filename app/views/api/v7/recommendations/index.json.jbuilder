json.meta do
  json.status "ok"
  json.set! :"message-type", "recommendation-list"
  json.set! :"message-version", "v7"
  json.total @recommendations.total_entries
  json.total_pages @recommendations.per_page > 0 ? @recommendations.total_pages : 1
  json.page @recommendations.total_entries > 0 ? @recommendations.current_page : 1
end

json.recommendations @recommendations do |recommendation|
  json.cache! ['v7', "recommendation", recommendation, params[:work_id], params[:source_id], params[:relation_type_id]], skip_digest: true do
    json.(recommendation, :subj_id, :obj_id, :source_id, :publisher_id, :relation_type_id)
    json.(recommendation.work, :author, :title, :issued)
    json.set! :"container-title", recommendation.work.container_title
    json.(recommendation.work, :volume, :page, :issue, :DOI, :URL, :PMID, :PMCID, :arxiv, :scp, :wos, :ark, :events)
    json.(recommendation, :timestamp)
  end
end
