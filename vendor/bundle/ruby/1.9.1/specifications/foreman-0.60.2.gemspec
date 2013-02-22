# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "foreman"
  s.version = "0.60.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Dollar"]
  s.date = "2012-10-08"
  s.description = "Process manager for applications with multiple components"
  s.email = "ddollar@gmail.com"
  s.executables = ["foreman"]
  s.files = ["bin/foreman"]
  s.homepage = "http://github.com/ddollar/foreman"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Process manager for applications with multiple components"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<thor>, [">= 0.13.6"])
    else
      s.add_dependency(%q<thor>, [">= 0.13.6"])
    end
  else
    s.add_dependency(%q<thor>, [">= 0.13.6"])
  end
end
