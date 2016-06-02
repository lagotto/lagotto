json.meta do
  json.status "ok"
  json.set! :"message-type", "relation-list"
  json.set! :"message-version", "v7"
  json.total @relations.total_entries
  json.total_pages @relations.per_page > 0 ? @relations.total_pages : 1
  json.page @relations.total_entries > 0 ? @relations.current_page : 1
  json.sources @sources
  json.relation_types @relation_types
end

json.relations @relations do |relation|
  json.cache! ['v7', "relation", relation, params[:work_id], params[:source_id], params[:relation_type_id]], skip_digest: true do
    json.(relation, :subj_id, :obj_id, :source_id, :publisher_id, :relation_type_id, :total)
    json.(relation.work, :author, :title, :published, :issued)
    json.set! :"container-title", relation.work.container_title
    json.(relation.work, :volume, :page, :issue, :DOI, :URL, :PMID, :PMCID, :arxiv, :scp, :wos, :ark, :publisher_id, :work_type_id, :results)
    json.(relation, :implicit, :timestamp)
  end
end
