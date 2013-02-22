# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "poltergeist"
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jon Leighton"]
  s.date = "2012-10-30"
  s.description = "PhantomJS driver for Capybara"
  s.email = ["j@jonathanleighton.com"]
  s.homepage = "http://github.com/jonleighton/poltergeist"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "PhantomJS driver for Capybara"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capybara>, ["~> 1.1"])
      s.add_runtime_dependency(%q<multi_json>, ["~> 1.0"])
      s.add_runtime_dependency(%q<childprocess>, ["~> 0.3"])
      s.add_runtime_dependency(%q<http_parser.rb>, ["~> 0.5.3"])
      s.add_runtime_dependency(%q<faye-websocket>, [">= 0.4.4", "~> 0.4"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8"])
      s.add_development_dependency(%q<sinatra>, ["~> 1.0"])
      s.add_development_dependency(%q<rake>, ["~> 0.9.2"])
      s.add_development_dependency(%q<image_size>, ["~> 1.0"])
      s.add_development_dependency(%q<coffee-script>, ["~> 2.2.0"])
      s.add_development_dependency(%q<guard-coffeescript>, ["~> 1.0.0"])
      s.add_development_dependency(%q<rspec-rerun>, ["~> 0.1"])
    else
      s.add_dependency(%q<capybara>, ["~> 1.1"])
      s.add_dependency(%q<multi_json>, ["~> 1.0"])
      s.add_dependency(%q<childprocess>, ["~> 0.3"])
      s.add_dependency(%q<http_parser.rb>, ["~> 0.5.3"])
      s.add_dependency(%q<faye-websocket>, [">= 0.4.4", "~> 0.4"])
      s.add_dependency(%q<rspec>, ["~> 2.8"])
      s.add_dependency(%q<sinatra>, ["~> 1.0"])
      s.add_dependency(%q<rake>, ["~> 0.9.2"])
      s.add_dependency(%q<image_size>, ["~> 1.0"])
      s.add_dependency(%q<coffee-script>, ["~> 2.2.0"])
      s.add_dependency(%q<guard-coffeescript>, ["~> 1.0.0"])
      s.add_dependency(%q<rspec-rerun>, ["~> 0.1"])
    end
  else
    s.add_dependency(%q<capybara>, ["~> 1.1"])
    s.add_dependency(%q<multi_json>, ["~> 1.0"])
    s.add_dependency(%q<childprocess>, ["~> 0.3"])
    s.add_dependency(%q<http_parser.rb>, ["~> 0.5.3"])
    s.add_dependency(%q<faye-websocket>, [">= 0.4.4", "~> 0.4"])
    s.add_dependency(%q<rspec>, ["~> 2.8"])
    s.add_dependency(%q<sinatra>, ["~> 1.0"])
    s.add_dependency(%q<rake>, ["~> 0.9.2"])
    s.add_dependency(%q<image_size>, ["~> 1.0"])
    s.add_dependency(%q<coffee-script>, ["~> 2.2.0"])
    s.add_dependency(%q<guard-coffeescript>, ["~> 1.0.0"])
    s.add_dependency(%q<rspec-rerun>, ["~> 0.1"])
  end
end
