SUBSCRIBERS_CONFIG = if File.exists?("#{Rails.root.to_s}/config/subscribers.yml")
    YAML.load_file("#{Rails.root.to_s}/config/subscribers.yml")
else 
    { subscribers: [] }
end