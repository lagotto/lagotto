# configuration for custom logger of external API responses

if ENV["LOGSTASH_PATH"].present?
  # log to file, using logstash JSON format
  logstash_type = ENV["LOGSTASH_TYPE"] ? ENV["LOGSTASH_TYPE"].to_sym : :file

  # Optional, Redis will default to localhost
  logstash_host = ENV["LOGSTASH_HOST"] || "localhost"

  logstash_path = ENV["LOGSTASH_PATH"]

  AGENT_LOGGER = LogStashLogger.new(type: logstash_type, path: logstash_path, host: logstash_host)
end
