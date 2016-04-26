json.meta do
  json.status @status || "ok"
  json.set! :"message-type", "work"
  json.set! :"message-version", "v7"
end

json.work do
  json.cache! ['v7', @work], skip_digest: true do
    json.(@work, :id, :author, :title, :published, :issued, :updated)
    json.set! :"container-title", @work.container_title
    json.(@work, :volume, :page, :issue, :DOI, :URL, :PMID, :PMCID, :arxiv, :scp, :wos, :ark, :publisher_id, :registration_agency_id, :work_type_id, :results)
  end
end
