# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "mumboe-soap4r"
  s.version = "1.5.8.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Diedrick (modifier: swalterd)"]
  s.date = "2009-12-08"
  s.email = "swalterd@gmail.com"
  s.executables = ["wsdl2ruby.rb", "xsd2ruby.rb"]
  s.files = ["bin/wsdl2ruby.rb", "bin/xsd2ruby.rb"]
  s.homepage = "https://github.com/mumboe/soap4r"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "An implementation of SOAP 1.1 for Ruby."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httpclient>, [">= 2.1.1"])
    else
      s.add_dependency(%q<httpclient>, [">= 2.1.1"])
    end
  else
    s.add_dependency(%q<httpclient>, [">= 2.1.1"])
  end
end
