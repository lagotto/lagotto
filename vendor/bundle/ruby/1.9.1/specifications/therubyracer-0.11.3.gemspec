# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "therubyracer"
  s.version = "0.11.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Charles Lowell"]
  s.date = "2013-01-16"
  s.description = "Call JavaScript code and manipulate JavaScript objects from Ruby. Call Ruby code and manipulate Ruby objects from JavaScript."
  s.email = ["javascript-and-friends@googlegroups.com"]
  s.extensions = ["ext/v8/extconf.rb"]
  s.files = ["ext/v8/extconf.rb"]
  s.homepage = "http://github.com/cowboyd/therubyracer"
  s.require_paths = ["lib", "ext"]
  s.rubygems_version = "1.8.23"
  s.summary = "Embed the V8 JavaScript interpreter into Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ref>, [">= 0"])
      s.add_runtime_dependency(%q<libv8>, ["~> 3.11.8.12"])
    else
      s.add_dependency(%q<ref>, [">= 0"])
      s.add_dependency(%q<libv8>, ["~> 3.11.8.12"])
    end
  else
    s.add_dependency(%q<ref>, [">= 0"])
    s.add_dependency(%q<libv8>, ["~> 3.11.8.12"])
  end
end
