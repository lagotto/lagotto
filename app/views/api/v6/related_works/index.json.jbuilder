json.meta do
  json.status "ok"
  json.set! :"message-type", "related_work-list"
  json.set! :"message-version", "6.0.0"
  json.total @relationships.total_entries
  json.total_pages @relationships.per_page > 0 ? @relationships.total_pages : 1
  json.page @relationships.total_entries > 0 ? @relationships.current_page : 1
end

json.related_works @relationships do |relationship|
  json.cache! ['v6', "related_work", relationship, params[:work_id], params[:source_id], params[:relation_type_id]], skip_digest: true do
    json.(relationship.work, :id, :publisher_id)
    json.(relationship, :work_id, :source_id, :relation_type_id)
    json.(relationship.work, :title, :issued)
    json.set! :"container-title", relationship.work.container_title
    json.(relationship.work, :volume, :page, :issue, :DOI, :URL, :PMID, :PMCID, :scp, :wos, :ark, :events)
    json.(relationship, :timestamp)
  end
end
