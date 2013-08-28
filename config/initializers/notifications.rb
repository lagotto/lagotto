INTERNAL_PARAMS = %w(controller action format _method only_path)

ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
  if payload[:controller] == "Api::V3::ArticlesController"
    ApiRequest.create! do |api_request|
      api_request.format = payload[:format] || "html"
      api_request.view_duration = payload[:view_runtime]
      api_request.db_duration = payload[:db_runtime]
      params = payload[:params].except(*INTERNAL_PARAMS)
      api_request.api_key = params["api_key"]
      api_request.info = params["info"]
      api_request.source = params["source"]
      api_request.ids = params["ids"]
    end
  end
end

ActiveSupport::Notifications.subscribe "api_response.get" do |name, start, finish, id, payload|
  ApiResponse.create! do |api_response|
    api_response.article_id = payload[:article_id]
    api_response.source_id = payload[:source_id]
    api_response.retrieval_status_id = payload[:retrieval_status_id]
    api_response.retrieval_history_id = payload[:retrieval_history_id]
    api_response.event_count = payload[:event_count]
    api_response.previous_count = payload[:previous_count]
    api_response.duration = (finish - start) * 1000
  end
end
