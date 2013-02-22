# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ffi"
  s.version = "1.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Wayne Meissner"]
  s.date = "2013-02-16"
  s.description = "Ruby FFI library"
  s.email = "wmeissner@gmail.com"
  s.extensions = ["ext/ffi_c/extconf.rb"]
  s.files = ["ext/ffi_c/extconf.rb"]
  s.homepage = "http://wiki.github.com/ffi/ffi"
  s.licenses = ["LGPL-3"]
  s.require_paths = ["lib", "ext/ffi_c"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = "1.8.23"
  s.summary = "Ruby FFI"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rake-compiler>, [">= 0.6.0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rake-compiler>, [">= 0.6.0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rake-compiler>, [">= 0.6.0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
