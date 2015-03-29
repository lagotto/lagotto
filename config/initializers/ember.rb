EmberCLI.configure do |c|
  c.app :frontend, path: Rails.root.join("frontend").to_s
  ENV["SKIP_EMBER"] = 1
end
