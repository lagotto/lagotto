object @source

attributes :name, :display_name, :group, :description, :update_date

if current_user.is_admin_or_staff?
  attributes :state, :jobs, :responses, :error_count, :article_count, :event_count, :status, :by_day, :by_month
end
