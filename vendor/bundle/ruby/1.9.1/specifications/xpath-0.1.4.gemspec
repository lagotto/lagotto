# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "xpath"
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonas Nicklas"]
  s.date = "2011-04-24"
  s.description = "XPath is a Ruby DSL for generating XPath expressions"
  s.email = ["jonas.nicklas@gmail.com"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc"]
  s.homepage = "http://github.com/jnicklas/xpath"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "xpath"
  s.rubygems_version = "1.8.23"
  s.summary = "Generate XPath expressions from Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.3"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
      s.add_development_dependency(%q<yard>, [">= 0.5.8"])
    else
      s.add_dependency(%q<nokogiri>, ["~> 1.3"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
      s.add_dependency(%q<yard>, [">= 0.5.8"])
    end
  else
    s.add_dependency(%q<nokogiri>, ["~> 1.3"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
    s.add_dependency(%q<yard>, [">= 0.5.8"])
  end
end
