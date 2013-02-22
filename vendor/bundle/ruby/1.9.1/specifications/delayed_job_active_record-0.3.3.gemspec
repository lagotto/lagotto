# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "delayed_job_active_record"
  s.version = "0.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Ryckbost", "Matt Griffin", "Erik Michaels-Ober"]
  s.date = "2012-09-30"
  s.description = "ActiveRecord backend for DelayedJob, originally authored by Tobias Luetke"
  s.email = ["bryckbost@gmail.com", "matt@griffinonline.org", "sferik@gmail.com"]
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md"]
  s.homepage = "http://github.com/collectiveidea/delayed_job_active_record"
  s.rdoc_options = ["--main", "README.md", "--inline-source", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "ActiveRecord backend for DelayedJob"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, ["< 4", ">= 2.1.0"])
      s.add_runtime_dependency(%q<delayed_job>, ["~> 3.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, ["< 4", ">= 2.1.0"])
      s.add_dependency(%q<delayed_job>, ["~> 3.0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, ["< 4", ">= 2.1.0"])
    s.add_dependency(%q<delayed_job>, ["~> 3.0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
  end
end
