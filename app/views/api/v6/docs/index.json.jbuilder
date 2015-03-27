json.docs @docs do |doc|
  json.cache! ['v6', @doc], skip_digest: true do
    json.(doc, :id, :title, :update_date)
  end
end
