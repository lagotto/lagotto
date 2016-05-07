json.meta do
  json.status "ok"
  json.set! :"message-type", "registration-agency"
  json.set! :"message-version", "v7"
end

json.registration_agency do
  json.cache! ['v7', @registration_agency], skip_digest: true do
    json.(@registration_agency, :id, :title, :timestamp)
  end
end
