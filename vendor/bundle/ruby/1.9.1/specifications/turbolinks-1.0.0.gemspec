# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "turbolinks"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Heinemeier Hansson"]
  s.date = "2013-01-11"
  s.email = "david@loudthinking.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Turbolinks makes following links in your web application faster (use with Rails Asset Pipeline)"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<coffee-rails>, [">= 0"])
    else
      s.add_dependency(%q<coffee-rails>, [">= 0"])
    end
  else
    s.add_dependency(%q<coffee-rails>, [">= 0"])
  end
end
