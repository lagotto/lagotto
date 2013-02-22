# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "shoulda-matchers"
  s.version = "1.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tammer Saleh", "Joe Ferris", "Ryan McGeary", "Dan Croak", "Matt Jankowski", "Stafford Brunk"]
  s.date = "2012-11-30"
  s.description = "Making tests easy on the fingers and eyes"
  s.email = "support@thoughtbot.com"
  s.homepage = "http://thoughtbot.com/community/"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Making tests easy on the fingers and eyes"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_runtime_dependency(%q<bourne>, ["~> 1.1.2"])
      s.add_development_dependency(%q<appraisal>, ["~> 0.4.0"])
      s.add_development_dependency(%q<aruba>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.1"])
      s.add_development_dependency(%q<cucumber>, ["~> 1.1.9"])
      s.add_development_dependency(%q<rails>, ["~> 3.0"])
      s.add_development_dependency(%q<rake>, ["~> 0.9.2"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 2.8.1"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_dependency(%q<bourne>, ["~> 1.1.2"])
      s.add_dependency(%q<appraisal>, ["~> 0.4.0"])
      s.add_dependency(%q<aruba>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.1"])
      s.add_dependency(%q<cucumber>, ["~> 1.1.9"])
      s.add_dependency(%q<rails>, ["~> 3.0"])
      s.add_dependency(%q<rake>, ["~> 0.9.2"])
      s.add_dependency(%q<rspec-rails>, ["~> 2.8.1"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.0.0"])
    s.add_dependency(%q<bourne>, ["~> 1.1.2"])
    s.add_dependency(%q<appraisal>, ["~> 0.4.0"])
    s.add_dependency(%q<aruba>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.1"])
    s.add_dependency(%q<cucumber>, ["~> 1.1.9"])
    s.add_dependency(%q<rails>, ["~> 3.0"])
    s.add_dependency(%q<rake>, ["~> 0.9.2"])
    s.add_dependency(%q<rspec-rails>, ["~> 2.8.1"])
  end
end
