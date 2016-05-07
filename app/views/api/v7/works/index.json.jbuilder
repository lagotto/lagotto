json.meta do
  json.status "ok"
  json.set! :"message-type", "work-list"
  json.set! :"message-version", "v7"
  json.total @works.total_entries
  json.total_pages @works.per_page > 0 ? @works.total_pages : 1
  json.page @works.total_entries > 0 ? @works.current_page : 1
end

json.works @works do |work|
  json.cache! ['v7', work], skip_digest: true do
    json.(work, :id, :author, :title, :published, :issued, :updated)
    json.set! :"container-title", work.container_title
    json.(work, :volume, :page, :issue, :DOI, :URL, :PMID, :PMCID, :arxiv, :scp, :wos, :ark, :publisher_id, :registration_agency_id, :work_type_id, :results)
  end
end
