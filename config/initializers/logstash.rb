# configuration for custom logger of external API responses

# log to file, using logstash JSON format
logstash_type = ENV["LOGSTASH_TYPE"] ? ENV["LOGSTASH_TYPE"].to_sym : :file

# Optional, Redis will default to localhost
logstash_host = ENV["LOGSTASH_HOST"] || "localhost"

logstash_path = "log/agent.log"

AGENT_LOGGER = LogStashLogger.new(type: logstash_type, path: logstash_path, host: logstash_host)
