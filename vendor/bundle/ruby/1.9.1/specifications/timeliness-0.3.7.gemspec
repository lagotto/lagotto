# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "timeliness"
  s.version = "0.3.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adam Meehan"]
  s.date = "2012-10-03"
  s.description = "Fast date/time parser with customisable formats, timezone and I18n support."
  s.email = "adam.meehan@gmail.com"
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG.rdoc"]
  s.files = ["README.rdoc", "CHANGELOG.rdoc"]
  s.homepage = "http://github.com/adzap/timeliness"
  s.require_paths = ["lib"]
  s.rubyforge_project = "timeliness"
  s.rubygems_version = "1.8.23"
  s.summary = "Date/time parsing for the control freak."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
