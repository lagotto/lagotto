json.meta do
  json.status "ok"
  json.set! :"message-type", "similar_work-list"
  json.set! :"message-version", "6.0.0"
  json.total @similars.total_entries
  json.total_pages @similars.per_page > 0 ? @similars.total_pages : 1
  json.page @similars.total_entries > 0 ? @similars.current_page : 1
end

json.similar_works @similars do |similar|
  json.cache! ['v6', "similar_work", relation, params[:work_id], params[:source_id], params[:relation_type_id]], skip_digest: true do
    json.(similar.work, :id, :publisher_id)
    json.(similar, :work_id, :source_id, :relation_type_id)
    json.(similar.work, :title, :issued)
    json.set! :"container-title", similar.work.container_title
    json.(similar.work, :volume, :page, :issue, :DOI, :URL, :PMID, :PMCID, :scp, :wos, :ark, :events)
    json.(similar, :timestamp)
  end
end
