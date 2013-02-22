# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "request_store"
  s.version = "1.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Steve Klabnik"]
  s.date = "2013-01-09"
  s.description = "RequestStore gives you per-request global storage."
  s.email = ["steve@steveklabnik.com"]
  s.homepage = "http://github.com/steveklabnik/request_store"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "RequestStore gives you per-request global storage."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<minitest>, ["~> 3.0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<minitest>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<minitest>, ["~> 3.0"])
  end
end
