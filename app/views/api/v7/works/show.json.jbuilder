json.meta do
  json.status @status || "ok"
  json.set! :"message-type", "work"
  json.set! :"message-version", "v7"
end

json.work do
  json.cache! ['v7', @work], skip_digest: true do
    json.(@work, :id, :publisher_id, :author, :title, :issued)
    json.set! :"container-title", @work.container_title
    json.(@work, :volume, :page, :issue, :DOI, :URL, :PMID, :PMCID, :arxiv, :scp, :wos, :ark, :events, :timestamp)
  end
end
