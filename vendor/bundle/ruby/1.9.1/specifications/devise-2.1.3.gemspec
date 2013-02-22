# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "devise"
  s.version = "2.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jos\u{e9} Valim", "Carlos Ant\u{f4}nio"]
  s.date = "2013-01-26"
  s.description = "Flexible authentication solution for Rails with Warden"
  s.email = "contact@plataformatec.com.br"
  s.homepage = "http://github.com/plataformatec/devise"
  s.require_paths = ["lib"]
  s.rubyforge_project = "devise"
  s.rubygems_version = "1.8.23"
  s.summary = "Flexible authentication solution for Rails with Warden"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<warden>, ["~> 1.2.1"])
      s.add_runtime_dependency(%q<orm_adapter>, ["~> 0.1"])
      s.add_runtime_dependency(%q<bcrypt-ruby>, ["~> 3.0"])
      s.add_runtime_dependency(%q<railties>, ["~> 3.1"])
    else
      s.add_dependency(%q<warden>, ["~> 1.2.1"])
      s.add_dependency(%q<orm_adapter>, ["~> 0.1"])
      s.add_dependency(%q<bcrypt-ruby>, ["~> 3.0"])
      s.add_dependency(%q<railties>, ["~> 3.1"])
    end
  else
    s.add_dependency(%q<warden>, ["~> 1.2.1"])
    s.add_dependency(%q<orm_adapter>, ["~> 0.1"])
    s.add_dependency(%q<bcrypt-ruby>, ["~> 3.0"])
    s.add_dependency(%q<railties>, ["~> 3.1"])
  end
end
