json.total @status.total_entries
json.total_pages (@status.total_entries.to_f / @status.per_page).ceil
json.page @status.total_entries > 0 ? @status.current_page : 0
json.error @error

json.data @status do |status|
  json.cache! ['v5', status, @user], skip_digest: true do
    json.(status, :works_count, :sources, :events_count, :responses_count, :requests_count, :requests_average, :version, :update_date)

    if current_user && current_user.is_admin_or_staff?
      json.(status, :alerts_count, :db_size)
    end
  end
end
