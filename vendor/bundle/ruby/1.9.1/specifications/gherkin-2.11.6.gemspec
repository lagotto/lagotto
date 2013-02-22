# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "gherkin"
  s.version = "2.11.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Sassak", "Gregory Hnatiuk", "Aslak Helles\u{f8}y"]
  s.date = "2013-01-29"
  s.description = "A fast Gherkin lexer/parser based on the Ragel State Machine Compiler."
  s.email = "cukes@googlegroups.com"
  s.extensions = ["ext/gherkin_lexer_ar/extconf.rb", "ext/gherkin_lexer_bg/extconf.rb", "ext/gherkin_lexer_bm/extconf.rb", "ext/gherkin_lexer_ca/extconf.rb", "ext/gherkin_lexer_cs/extconf.rb", "ext/gherkin_lexer_cy_gb/extconf.rb", "ext/gherkin_lexer_da/extconf.rb", "ext/gherkin_lexer_de/extconf.rb", "ext/gherkin_lexer_en/extconf.rb", "ext/gherkin_lexer_en_au/extconf.rb", "ext/gherkin_lexer_en_lol/extconf.rb", "ext/gherkin_lexer_en_pirate/extconf.rb", "ext/gherkin_lexer_en_scouse/extconf.rb", "ext/gherkin_lexer_en_tx/extconf.rb", "ext/gherkin_lexer_eo/extconf.rb", "ext/gherkin_lexer_es/extconf.rb", "ext/gherkin_lexer_et/extconf.rb", "ext/gherkin_lexer_fa/extconf.rb", "ext/gherkin_lexer_fi/extconf.rb", "ext/gherkin_lexer_fr/extconf.rb", "ext/gherkin_lexer_he/extconf.rb", "ext/gherkin_lexer_hi/extconf.rb", "ext/gherkin_lexer_hr/extconf.rb", "ext/gherkin_lexer_hu/extconf.rb", "ext/gherkin_lexer_id/extconf.rb", "ext/gherkin_lexer_is/extconf.rb", "ext/gherkin_lexer_it/extconf.rb", "ext/gherkin_lexer_ja/extconf.rb", "ext/gherkin_lexer_ko/extconf.rb", "ext/gherkin_lexer_lt/extconf.rb", "ext/gherkin_lexer_lu/extconf.rb", "ext/gherkin_lexer_lv/extconf.rb", "ext/gherkin_lexer_nl/extconf.rb", "ext/gherkin_lexer_no/extconf.rb", "ext/gherkin_lexer_pl/extconf.rb", "ext/gherkin_lexer_pt/extconf.rb", "ext/gherkin_lexer_ro/extconf.rb", "ext/gherkin_lexer_ru/extconf.rb", "ext/gherkin_lexer_sk/extconf.rb", "ext/gherkin_lexer_sr_cyrl/extconf.rb", "ext/gherkin_lexer_sr_latn/extconf.rb", "ext/gherkin_lexer_sv/extconf.rb", "ext/gherkin_lexer_tl/extconf.rb", "ext/gherkin_lexer_tr/extconf.rb", "ext/gherkin_lexer_tt/extconf.rb", "ext/gherkin_lexer_uk/extconf.rb", "ext/gherkin_lexer_uz/extconf.rb", "ext/gherkin_lexer_vi/extconf.rb", "ext/gherkin_lexer_zh_cn/extconf.rb", "ext/gherkin_lexer_zh_tw/extconf.rb"]
  s.files = ["ext/gherkin_lexer_ar/extconf.rb", "ext/gherkin_lexer_bg/extconf.rb", "ext/gherkin_lexer_bm/extconf.rb", "ext/gherkin_lexer_ca/extconf.rb", "ext/gherkin_lexer_cs/extconf.rb", "ext/gherkin_lexer_cy_gb/extconf.rb", "ext/gherkin_lexer_da/extconf.rb", "ext/gherkin_lexer_de/extconf.rb", "ext/gherkin_lexer_en/extconf.rb", "ext/gherkin_lexer_en_au/extconf.rb", "ext/gherkin_lexer_en_lol/extconf.rb", "ext/gherkin_lexer_en_pirate/extconf.rb", "ext/gherkin_lexer_en_scouse/extconf.rb", "ext/gherkin_lexer_en_tx/extconf.rb", "ext/gherkin_lexer_eo/extconf.rb", "ext/gherkin_lexer_es/extconf.rb", "ext/gherkin_lexer_et/extconf.rb", "ext/gherkin_lexer_fa/extconf.rb", "ext/gherkin_lexer_fi/extconf.rb", "ext/gherkin_lexer_fr/extconf.rb", "ext/gherkin_lexer_he/extconf.rb", "ext/gherkin_lexer_hi/extconf.rb", "ext/gherkin_lexer_hr/extconf.rb", "ext/gherkin_lexer_hu/extconf.rb", "ext/gherkin_lexer_id/extconf.rb", "ext/gherkin_lexer_is/extconf.rb", "ext/gherkin_lexer_it/extconf.rb", "ext/gherkin_lexer_ja/extconf.rb", "ext/gherkin_lexer_ko/extconf.rb", "ext/gherkin_lexer_lt/extconf.rb", "ext/gherkin_lexer_lu/extconf.rb", "ext/gherkin_lexer_lv/extconf.rb", "ext/gherkin_lexer_nl/extconf.rb", "ext/gherkin_lexer_no/extconf.rb", "ext/gherkin_lexer_pl/extconf.rb", "ext/gherkin_lexer_pt/extconf.rb", "ext/gherkin_lexer_ro/extconf.rb", "ext/gherkin_lexer_ru/extconf.rb", "ext/gherkin_lexer_sk/extconf.rb", "ext/gherkin_lexer_sr_cyrl/extconf.rb", "ext/gherkin_lexer_sr_latn/extconf.rb", "ext/gherkin_lexer_sv/extconf.rb", "ext/gherkin_lexer_tl/extconf.rb", "ext/gherkin_lexer_tr/extconf.rb", "ext/gherkin_lexer_tt/extconf.rb", "ext/gherkin_lexer_uk/extconf.rb", "ext/gherkin_lexer_uz/extconf.rb", "ext/gherkin_lexer_vi/extconf.rb", "ext/gherkin_lexer_zh_cn/extconf.rb", "ext/gherkin_lexer_zh_tw/extconf.rb"]
  s.homepage = "http://github.com/cucumber/gherkin"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "gherkin-2.11.6"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake-compiler>, [">= 0.8.2"])
      s.add_runtime_dependency(%q<json>, [">= 1.7.6"])
      s.add_development_dependency(%q<cucumber>, [">= 1.2.1"])
      s.add_development_dependency(%q<rake>, [">= 10.0.3"])
      s.add_development_dependency(%q<bundler>, [">= 1.2.3"])
      s.add_development_dependency(%q<rspec>, ["~> 2.12.0"])
      s.add_development_dependency(%q<rubyzip>, [">= 0.9.9"])
      s.add_development_dependency(%q<therubyracer>, [">= 0.11.2"])
      s.add_development_dependency(%q<yard>, [">= 0.8.3"])
      s.add_development_dependency(%q<rdiscount>, [">= 1.6.8"])
      s.add_development_dependency(%q<term-ansicolor>, [">= 1.0.7"])
      s.add_development_dependency(%q<builder>, [">= 3.1.4"])
    else
      s.add_dependency(%q<rake-compiler>, [">= 0.8.2"])
      s.add_dependency(%q<json>, [">= 1.7.6"])
      s.add_dependency(%q<cucumber>, [">= 1.2.1"])
      s.add_dependency(%q<rake>, [">= 10.0.3"])
      s.add_dependency(%q<bundler>, [">= 1.2.3"])
      s.add_dependency(%q<rspec>, ["~> 2.12.0"])
      s.add_dependency(%q<rubyzip>, [">= 0.9.9"])
      s.add_dependency(%q<therubyracer>, [">= 0.11.2"])
      s.add_dependency(%q<yard>, [">= 0.8.3"])
      s.add_dependency(%q<rdiscount>, [">= 1.6.8"])
      s.add_dependency(%q<term-ansicolor>, [">= 1.0.7"])
      s.add_dependency(%q<builder>, [">= 3.1.4"])
    end
  else
    s.add_dependency(%q<rake-compiler>, [">= 0.8.2"])
    s.add_dependency(%q<json>, [">= 1.7.6"])
    s.add_dependency(%q<cucumber>, [">= 1.2.1"])
    s.add_dependency(%q<rake>, [">= 10.0.3"])
    s.add_dependency(%q<bundler>, [">= 1.2.3"])
    s.add_dependency(%q<rspec>, ["~> 2.12.0"])
    s.add_dependency(%q<rubyzip>, [">= 0.9.9"])
    s.add_dependency(%q<therubyracer>, [">= 0.11.2"])
    s.add_dependency(%q<yard>, [">= 0.8.3"])
    s.add_dependency(%q<rdiscount>, [">= 1.6.8"])
    s.add_dependency(%q<term-ansicolor>, [">= 1.0.7"])
    s.add_dependency(%q<builder>, [">= 3.1.4"])
  end
end
