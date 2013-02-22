# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ref"
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Durand"]
  s.date = "2012-11-08"
  s.description = "Library that implements weak, soft, and strong references in Ruby that work across multiple runtimes (MRI, REE, YARV, Jruby, Rubinius, and IronRuby). Also includes implementation of maps/hashes that use references and a reference queue."
  s.email = ["bdurand@embellishedvisions.com"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc"]
  s.homepage = "http://github.com/bdurand/ref"
  s.rdoc_options = ["--charset=UTF-8", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Library that implements weak, soft, and strong references in Ruby."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
