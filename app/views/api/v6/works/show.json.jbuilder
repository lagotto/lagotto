json.meta do
  json.status @status || "ok"
  json.set! :"message-type", "work"
  json.set! :"message-version", "6.0.0"
end

json.work do
  json.cache! ['v6', @work], skip_digest: true do
    json.(@work, :id, :publisher_id, :title, :issued)
    json.set! :"container-title", @work.container_title
    json.(@work, :volume, :page, :issue, :DOI, :URL, :PMID, :PMCID, :arxiv, :scp, :wos, :ark, :events, :timestamp)
  end
end
