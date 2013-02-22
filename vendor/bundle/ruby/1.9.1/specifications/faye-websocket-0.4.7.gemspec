# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "faye-websocket"
  s.version = "0.4.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Coglan"]
  s.date = "2013-02-15"
  s.email = "jcoglan@gmail.com"
  s.extensions = ["ext/faye_websocket_mask/extconf.rb"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "ext/faye_websocket_mask/extconf.rb"]
  s.homepage = "http://github.com/faye/faye-websocket-ruby"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Standards-compliant WebSocket server and client"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, [">= 0.12.0"])
      s.add_development_dependency(%q<progressbar>, [">= 0"])
      s.add_development_dependency(%q<rack>, [">= 0"])
      s.add_development_dependency(%q<rake-compiler>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rainbows>, [">= 1.0.0"])
      s.add_development_dependency(%q<thin>, [">= 1.2.0"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0.12.0"])
      s.add_dependency(%q<progressbar>, [">= 0"])
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<rake-compiler>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rainbows>, [">= 1.0.0"])
      s.add_dependency(%q<thin>, [">= 1.2.0"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0.12.0"])
    s.add_dependency(%q<progressbar>, [">= 0"])
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<rake-compiler>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rainbows>, [">= 1.0.0"])
    s.add_dependency(%q<thin>, [">= 1.2.0"])
  end
end
