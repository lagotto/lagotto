json.meta do
  json.status "ok"
  json.set! :"message-type", "reference-list"
  json.set! :"message-version", "6.0.0"
  json.total @references.total_entries
  json.total_pages @references.per_page > 0 ? @references.total_pages : 1
  json.page @references.total_entries > 0 ? @references.current_page : 1
end

json.references @references do |reference|
  json.cache! ['v6', "reference", reference, params[:work_id], params[:source_id], params[:relation_type_id]], skip_digest: true do

    json.(reference.related_work, :id, :title, :issued, :container_title, :volume, :page, :issue, :publisher_id, :doi, :url, :pmid, :pmcid, :scp, :wos, :ark, :metrics)
    json.(reference, :reference_id, :source_id, :relation_type_id, :update_date)
  end
end
