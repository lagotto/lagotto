# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "crossfilter-rails"
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Vlad Gorodetsky"]
  s.date = "2013-01-08"
  s.description = "Fast n-dimensional filtering and grouping of records."
  s.email = ["v@gor.io"]
  s.homepage = "http://github.com/bai/crossfilter-rails"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Gemified crossfilter.js asset for Rails"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>, ["< 5.0", ">= 3.0"])
    else
      s.add_dependency(%q<railties>, ["< 5.0", ">= 3.0"])
    end
  else
    s.add_dependency(%q<railties>, ["< 5.0", ">= 3.0"])
  end
end
