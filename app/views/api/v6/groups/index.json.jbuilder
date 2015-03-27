json.groups @groups do |group|
  json.cache! ['v6', group], skip_digest: true do
    json.(group, :id, :title, :sources, :update_date)
  end
end
