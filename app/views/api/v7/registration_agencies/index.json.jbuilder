json.meta do
  json.status "ok"
  json.set! :"message-type", "registration-agency-list"
  json.set! :"message-version", "v7"
  json.total @registration_agencies.size
end

json.registration_agencies @registration_agencies do |registration_agency|
  json.cache! ['v7', registration_agency], skip_digest: true do
    json.(registration_agency, :id, :title, :timestamp)
  end
end
