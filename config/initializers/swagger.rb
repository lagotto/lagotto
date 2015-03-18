Swagger::Docs::Config.register_apis(
  "v5" => {
    api_file_path: "public",
    base_api_controller: "Api::V5::BaseController",
    base_path: "http://#{ENV['SERVERNAME']}",
    :attributes => {
      :info => {
        "title" => "API",
        "description" => "This is the live documentation of the Lagotto API. The current API is v5, please use <a href='http://#{ENV['SERVERNAME']}/api/v5'>http://#{ENV['SERVERNAME']}/api/v5</a> as base URL. Go to <a href='http://discuss.lagotto.io'>http://discuss.lagotto.io</a> for questions or comments regarding the Lagotto API." }
    }
  }
)
