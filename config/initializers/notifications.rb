INTERNAL_PARAMS = %w(controller action format _method only_path)

ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
  if payload[:method] == "GET" && payload[:status].to_i < 400
    ApiRequest.create! do |api_request|
      api_request.uuid = SecureRandom.uuid
      api_request.format = payload[:format] || "json"
      api_request.view_duration = payload[:view_runtime]
      api_request.db_duration = payload[:db_runtime]
      api_request.duration = payload[:view_runtime].to_f + payload[:db_runtime].to_f
      params = payload[:params].except(*INTERNAL_PARAMS)
      api_request.api_key = params["api_key"]
      api_request.info = params["info"]
      if params["source"] || params["ids"]
        api_request.source = params["source"]
        api_request.ids = params["ids"]
      else
        api_request.source = params["id"]
        api_request.ids = payload[:controller]
      end
    end
  end
end

ActiveSupport::Notifications.subscribe "api_response.get" do |name, start, finish, id, payload|
  ApiResponse.create! do |api_response|
    api_response.work_id = payload.fetch(:work_id, nil)
    api_response.source_id = payload.fetch(:source_id, nil)
    api_response.retrieval_status_id = payload.fetch(:retrieval_status_id, nil)
    api_response.skipped = payload.fetch(:skipped, false)
    api_response.total = payload.fetch(:total, 0)
    api_response.previous_total = payload.fetch(:previous_total, 0)
    api_response.html = payload.fetch(:html, 0)
    api_response.pdf = payload.fetch(:pdf, 0)
    api_response.update_interval = payload.fetch(:update_interval, 0)
    api_response.duration = (finish - start) * 1000
  end
end
