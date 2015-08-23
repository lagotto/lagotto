json.meta do
  json.status "ok"
  json.set! :"message-type", "reference-list"
  json.set! :"message-version", "6.0.0"
  json.total @reference_relations.total_entries
  json.total_pages @reference_relations.per_page > 0 ? @reference_relations.total_pages : 1
  json.page @reference_relations.total_entries > 0 ? @reference_relations.current_page : 1
end

json.references @reference_relations do |relation|
  json.cache! ['v6', "reference", relation, params[:work_id], params[:source_id], params[:relation_type_id]], skip_digest: true do
    json.(relation.related_work, :id, :publisher_id)
    json.(relation, :work_id, :source_id, :relation_type_id)
    json.(relation.related_work, :author, :title, :issued)
    json.set! :"container-title", relation.related_work.container_title
    json.(relation.related_work, :volume, :page, :issue, :DOI, :URL, :PMID, :PMCID, :arxiv, :scp, :wos, :ark, :events)
    json.(relation, :timestamp)
  end
end
