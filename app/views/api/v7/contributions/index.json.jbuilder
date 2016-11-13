json.meta do
  json.status "ok"
  json.set! :"message-type", "contribution-list"
  json.set! :"message-version", "v7"
  json.total @contributions.total_entries
  json.total_pages @contributions.per_page > 0 ? @contributions.total_pages : 1
  json.page @contributions.total_entries > 0 ? @contributions.current_page : 1
  json.sources @sources
  json.publishers @publishers
end

json.contributions @contributions do |contribution|
  json.cache! ['v7', "contribution", contribution, params[:contributor_id], params[:source_id], params[:contributor_role_id]], skip_digest: true do
    json.(contribution, :subj_id)
    json.(contribution.contributor, :given, :family, :credit_name)
    json.(contribution, :obj_id)
    json.(contribution.work, :author, :title, :published, :issued)
    json.set! :"container-title", contribution.work.container_title
    json.(contribution.work, :volume, :page, :issue, :DOI, :URL, :PMID, :PMCID, :arxiv, :scp, :wos, :ark, :publisher_id, :work_type_id, :results)
    json.(contribution, :source_id, :publisher_id, :contributor_role_id, :timestamp)
  end
end
