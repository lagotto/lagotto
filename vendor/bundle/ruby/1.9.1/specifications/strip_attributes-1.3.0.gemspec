# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "strip_attributes"
  s.version = "1.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan McGeary"]
  s.date = "2013-02-06"
  s.description = "StripAttributes automatically strips all ActiveRecord model attributes of leading and trailing whitespace before validation. If the attribute is blank, it strips the value to nil."
  s.email = ["ryan@mcgeary.org"]
  s.homepage = "https://github.com/rmm5t/strip_attributes"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Whitespace cleanup for ActiveModel attributes"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activemodel>, ["~> 3.0"])
      s.add_development_dependency(%q<minitest-matchers>, ["~> 1.2"])
      s.add_development_dependency(%q<activerecord>, ["~> 3.0"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
    else
      s.add_dependency(%q<activemodel>, ["~> 3.0"])
      s.add_dependency(%q<minitest-matchers>, ["~> 1.2"])
      s.add_dependency(%q<activerecord>, ["~> 3.0"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
    end
  else
    s.add_dependency(%q<activemodel>, ["~> 3.0"])
    s.add_dependency(%q<minitest-matchers>, ["~> 1.2"])
    s.add_dependency(%q<activerecord>, ["~> 3.0"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
  end
end
