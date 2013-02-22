# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "simple_form"
  s.version = "2.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jos\u{e9} Valim", "Carlos Ant\u{f4}nio", "Rafael Fran\u{e7}a"]
  s.date = "2012-10-08"
  s.description = "Forms made easy!"
  s.email = "contact@plataformatec.com.br"
  s.homepage = "https://github.com/plataformatec/simple_form"
  s.require_paths = ["lib"]
  s.rubyforge_project = "simple_form"
  s.rubygems_version = "1.8.23"
  s.summary = "Forms made easy!"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activemodel>, ["~> 3.0"])
      s.add_runtime_dependency(%q<actionpack>, ["~> 3.0"])
    else
      s.add_dependency(%q<activemodel>, ["~> 3.0"])
      s.add_dependency(%q<actionpack>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<activemodel>, ["~> 3.0"])
    s.add_dependency(%q<actionpack>, ["~> 3.0"])
  end
end
