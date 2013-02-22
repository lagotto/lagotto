# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rspec-rails"
  s.version = "2.12.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Chelimsky"]
  s.date = "2013-01-12"
  s.description = "RSpec for Rails"
  s.email = "rspec-users@rubyforge.org"
  s.homepage = "http://github.com/rspec/rspec-rails"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "rspec"
  s.rubygems_version = "1.8.23"
  s.summary = "rspec-rails-2.12.2"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0"])
      s.add_runtime_dependency(%q<actionpack>, [">= 3.0"])
      s.add_runtime_dependency(%q<railties>, [">= 3.0"])
      s.add_runtime_dependency(%q<rspec-core>, ["~> 2.12.0"])
      s.add_runtime_dependency(%q<rspec-expectations>, ["~> 2.12.0"])
      s.add_runtime_dependency(%q<rspec-mocks>, ["~> 2.12.0"])
      s.add_development_dependency(%q<rake>, ["~> 10.0.0"])
      s.add_development_dependency(%q<cucumber>, ["~> 1.1.9"])
      s.add_development_dependency(%q<aruba>, ["~> 0.4.11"])
      s.add_development_dependency(%q<ZenTest>, ["= 4.6.2"])
      s.add_development_dependency(%q<ammeter>, ["= 0.2.5"])
      s.add_development_dependency(%q<capybara>, [">= 2.0.0.beta4"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.0"])
      s.add_dependency(%q<actionpack>, [">= 3.0"])
      s.add_dependency(%q<railties>, [">= 3.0"])
      s.add_dependency(%q<rspec-core>, ["~> 2.12.0"])
      s.add_dependency(%q<rspec-expectations>, ["~> 2.12.0"])
      s.add_dependency(%q<rspec-mocks>, ["~> 2.12.0"])
      s.add_dependency(%q<rake>, ["~> 10.0.0"])
      s.add_dependency(%q<cucumber>, ["~> 1.1.9"])
      s.add_dependency(%q<aruba>, ["~> 0.4.11"])
      s.add_dependency(%q<ZenTest>, ["= 4.6.2"])
      s.add_dependency(%q<ammeter>, ["= 0.2.5"])
      s.add_dependency(%q<capybara>, [">= 2.0.0.beta4"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.0"])
    s.add_dependency(%q<actionpack>, [">= 3.0"])
    s.add_dependency(%q<railties>, [">= 3.0"])
    s.add_dependency(%q<rspec-core>, ["~> 2.12.0"])
    s.add_dependency(%q<rspec-expectations>, ["~> 2.12.0"])
    s.add_dependency(%q<rspec-mocks>, ["~> 2.12.0"])
    s.add_dependency(%q<rake>, ["~> 10.0.0"])
    s.add_dependency(%q<cucumber>, ["~> 1.1.9"])
    s.add_dependency(%q<aruba>, ["~> 0.4.11"])
    s.add_dependency(%q<ZenTest>, ["= 4.6.2"])
    s.add_dependency(%q<ammeter>, ["= 0.2.5"])
    s.add_dependency(%q<capybara>, [">= 2.0.0.beta4"])
  end
end
