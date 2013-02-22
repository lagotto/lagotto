# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "delayed_job"
  s.version = "3.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brandon Keepers", "Brian Ryckbost", "Chris Gaffney", "David Genord II", "Erik Michaels-Ober", "Matt Griffin", "Steve Richert", "Tobias L\u{fc}tke"]
  s.date = "2013-01-28"
  s.description = "Delayed_job (or DJ) encapsulates the common pattern of asynchronously executing longer tasks in the background. It is a direct extraction from Shopify where the job table is responsible for a multitude of core tasks."
  s.email = ["brian@collectiveidea.com"]
  s.homepage = "http://github.com/collectiveidea/delayed_job"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Database-backed asynchronous priority queue system -- Extracted from Shopify"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.0"])
    else
      s.add_dependency(%q<activesupport>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 3.0"])
  end
end
