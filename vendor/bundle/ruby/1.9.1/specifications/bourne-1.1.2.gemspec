# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "bourne"
  s.version = "1.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joe Ferris"]
  s.date = "2012-03-23"
  s.description = "Extends mocha to allow detailed tracking and querying of\n    stub and mock invocations. Allows test spies using the have_received rspec\n    matcher and assert_received for Test::Unit. Extracted from the\n    jferris-mocha fork."
  s.email = "jferris@thoughtbot.com"
  s.homepage = "http://github.com/thoughtbot/bourne"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Adds test spies to mocha."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mocha>, ["= 0.10.5"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<mocha>, ["= 0.10.5"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<mocha>, ["= 0.10.5"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
