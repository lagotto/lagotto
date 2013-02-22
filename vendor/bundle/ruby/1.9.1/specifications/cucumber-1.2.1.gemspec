# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "cucumber"
  s.version = "1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aslak Helles\u{f8}y"]
  s.date = "2012-06-09"
  s.description = "Behaviour Driven Development with elegance and joy"
  s.email = "cukes@googlegroups.com"
  s.executables = ["cucumber"]
  s.files = ["bin/cucumber"]
  s.homepage = "http://cukes.info"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "cucumber-1.2.1"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<gherkin>, ["~> 2.11.0"])
      s.add_runtime_dependency(%q<builder>, [">= 2.1.2"])
      s.add_runtime_dependency(%q<diff-lcs>, [">= 1.1.3"])
      s.add_runtime_dependency(%q<json>, [">= 1.4.6"])
      s.add_development_dependency(%q<aruba>, ["~> 0.4.11"])
      s.add_development_dependency(%q<rake>, [">= 0.9.2"])
      s.add_development_dependency(%q<rspec>, ["~> 2.10.0"])
      s.add_development_dependency(%q<nokogiri>, [">= 1.5.2"])
      s.add_development_dependency(%q<syntax>, [">= 1.0.0"])
      s.add_development_dependency(%q<spork>, [">= 1.0.0.rc2"])
      s.add_development_dependency(%q<simplecov>, [">= 0.6.2"])
      s.add_development_dependency(%q<yard>, ["~> 0.8.0"])
      s.add_development_dependency(%q<rdiscount>, ["~> 1.6.8"])
      s.add_development_dependency(%q<bcat>, ["~> 0.6.2"])
      s.add_development_dependency(%q<ramaze>, [">= 0"])
      s.add_development_dependency(%q<rack-test>, [">= 0.6.1"])
      s.add_development_dependency(%q<webrat>, [">= 0.7.3"])
      s.add_development_dependency(%q<sinatra>, [">= 1.3.2"])
      s.add_development_dependency(%q<capybara>, [">= 1.1.2"])
    else
      s.add_dependency(%q<gherkin>, ["~> 2.11.0"])
      s.add_dependency(%q<builder>, [">= 2.1.2"])
      s.add_dependency(%q<diff-lcs>, [">= 1.1.3"])
      s.add_dependency(%q<json>, [">= 1.4.6"])
      s.add_dependency(%q<aruba>, ["~> 0.4.11"])
      s.add_dependency(%q<rake>, [">= 0.9.2"])
      s.add_dependency(%q<rspec>, ["~> 2.10.0"])
      s.add_dependency(%q<nokogiri>, [">= 1.5.2"])
      s.add_dependency(%q<syntax>, [">= 1.0.0"])
      s.add_dependency(%q<spork>, [">= 1.0.0.rc2"])
      s.add_dependency(%q<simplecov>, [">= 0.6.2"])
      s.add_dependency(%q<yard>, ["~> 0.8.0"])
      s.add_dependency(%q<rdiscount>, ["~> 1.6.8"])
      s.add_dependency(%q<bcat>, ["~> 0.6.2"])
      s.add_dependency(%q<ramaze>, [">= 0"])
      s.add_dependency(%q<rack-test>, [">= 0.6.1"])
      s.add_dependency(%q<webrat>, [">= 0.7.3"])
      s.add_dependency(%q<sinatra>, [">= 1.3.2"])
      s.add_dependency(%q<capybara>, [">= 1.1.2"])
    end
  else
    s.add_dependency(%q<gherkin>, ["~> 2.11.0"])
    s.add_dependency(%q<builder>, [">= 2.1.2"])
    s.add_dependency(%q<diff-lcs>, [">= 1.1.3"])
    s.add_dependency(%q<json>, [">= 1.4.6"])
    s.add_dependency(%q<aruba>, ["~> 0.4.11"])
    s.add_dependency(%q<rake>, [">= 0.9.2"])
    s.add_dependency(%q<rspec>, ["~> 2.10.0"])
    s.add_dependency(%q<nokogiri>, [">= 1.5.2"])
    s.add_dependency(%q<syntax>, [">= 1.0.0"])
    s.add_dependency(%q<spork>, [">= 1.0.0.rc2"])
    s.add_dependency(%q<simplecov>, [">= 0.6.2"])
    s.add_dependency(%q<yard>, ["~> 0.8.0"])
    s.add_dependency(%q<rdiscount>, ["~> 1.6.8"])
    s.add_dependency(%q<bcat>, ["~> 0.6.2"])
    s.add_dependency(%q<ramaze>, [">= 0"])
    s.add_dependency(%q<rack-test>, [">= 0.6.1"])
    s.add_dependency(%q<webrat>, [">= 0.7.3"])
    s.add_dependency(%q<sinatra>, [">= 1.3.2"])
    s.add_dependency(%q<capybara>, [">= 1.1.2"])
  end
end
