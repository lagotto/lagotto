# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "launchy"
  s.version = "2.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Hinegardner"]
  s.date = "2012-08-06"
  s.description = "Launchy is helper class for launching cross-platform applications in a fire and forget manner. There are application concepts (browser, email client, etc) that are common across all platforms, and they may be launched differently on each platform. Launchy is here to make a common approach to launching external application from within ruby programs."
  s.email = "jeremy@copiousfreetime.org"
  s.executables = ["launchy"]
  s.extra_rdoc_files = ["HISTORY.rdoc", "Manifest.txt", "README.rdoc"]
  s.files = ["bin/launchy", "HISTORY.rdoc", "Manifest.txt", "README.rdoc"]
  s.homepage = "http://github.com/copiousfreetime/launchy"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Launchy is helper class for launching cross-platform applications in a fire and forget manner."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<addressable>, ["~> 2.3"])
      s.add_development_dependency(%q<rake>, ["~> 0.9.2.2"])
      s.add_development_dependency(%q<minitest>, ["~> 3.3.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<spoon>, ["~> 0.0.1"])
      s.add_development_dependency(%q<ffi>, ["~> 1.1.1"])
    else
      s.add_dependency(%q<addressable>, ["~> 2.3"])
      s.add_dependency(%q<rake>, ["~> 0.9.2.2"])
      s.add_dependency(%q<minitest>, ["~> 3.3.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<spoon>, ["~> 0.0.1"])
      s.add_dependency(%q<ffi>, ["~> 1.1.1"])
    end
  else
    s.add_dependency(%q<addressable>, ["~> 2.3"])
    s.add_dependency(%q<rake>, ["~> 0.9.2.2"])
    s.add_dependency(%q<minitest>, ["~> 3.3.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<spoon>, ["~> 0.0.1"])
    s.add_dependency(%q<ffi>, ["~> 1.1.1"])
  end
end
