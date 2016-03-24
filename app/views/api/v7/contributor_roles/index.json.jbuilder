json.meta do
  json.status "ok"
  json.set! :"message-type", "contributor_role-list"
  json.set! :"message-version", "v7"
  json.total @contributor_roles.size
end

json.contributor_roles @contributor_roles do |contributor_role|
  json.cache! ['v7', contributor_role], skip_digest: true do
    json.(contributor_role, :id, :title, :description, :image_url, :timestamp)
  end
end
