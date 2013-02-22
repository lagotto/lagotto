# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "http_parser.rb"
  s.version = "0.5.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marc-Andre Cournoyer", "Aman Gupta"]
  s.date = "2011-10-01"
  s.description = "Ruby bindings to http://github.com/ry/http-parser and http://github.com/a2800276/http-parser.java"
  s.email = ["macournoyer@gmail.com", "aman@tmm1.net"]
  s.extensions = ["ext/ruby_http_parser/extconf.rb"]
  s.files = ["ext/ruby_http_parser/extconf.rb"]
  s.homepage = "http://github.com/tmm1/http_parser.rb"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Simple callback-based HTTP request/response parser"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake-compiler>, [">= 0.7.9"])
      s.add_development_dependency(%q<rspec>, [">= 2.0.1"])
      s.add_development_dependency(%q<json>, [">= 1.4.6"])
      s.add_development_dependency(%q<yajl-ruby>, [">= 0.8.1"])
    else
      s.add_dependency(%q<rake-compiler>, [">= 0.7.9"])
      s.add_dependency(%q<rspec>, [">= 2.0.1"])
      s.add_dependency(%q<json>, [">= 1.4.6"])
      s.add_dependency(%q<yajl-ruby>, [">= 0.8.1"])
    end
  else
    s.add_dependency(%q<rake-compiler>, [">= 0.7.9"])
    s.add_dependency(%q<rspec>, [">= 2.0.1"])
    s.add_dependency(%q<json>, [">= 1.4.6"])
    s.add_dependency(%q<yajl-ruby>, [">= 0.8.1"])
  end
end
