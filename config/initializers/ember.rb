EmberCLI.configure do |c|
  c.app :frontend, exclude_ember_deps: "jquery"
end
