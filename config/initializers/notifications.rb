ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
  
  # Log a sample of API requests
  if payload[:controller] == "Api::V3::ArticlesController" and rand(100) < 100
    ApiRequest.create! do |page_request|
      page_request.path = payload[:path]
      page_request.format = payload[:format] || "html"
      page_request.page_duration = (finish - start) * 1000
      page_request.view_duration = payload[:view_runtime]
      page_request.db_duration = payload[:db_runtime]
    end
  end
end