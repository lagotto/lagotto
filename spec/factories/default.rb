FactoryGirl.define do

  factory :work do
    sequence(:pid) { |n| "http://doi.org/10.1371/journal.pone.00000#{n}" }
    provider_id "crossref"
  end

  factory :event do
    uuid { SecureRandom.uuid }
    source_id "citeulike"
    source_token "citeulike_123"
    pid "http://doi.org/10.1371/journal.pmed.0030186"
    modifier "add"
    field "relatedIdentifier"
    value "IsReferencedBy:DOI:http://doi.org/10.5061/DRYAD.47SD5/1"
    updated_at { Time.zone.now }
    occurred_at { Time.zone.now }
  end

  factory :source do
    name "citeulike"
    title "CiteULike"

    trait(:datacite) do
      name "datacite"
      title "DataCite"
    end

    trait(:mendeley) do
      name "mendeley"
      title "Mendeley"
    end

    trait(:facebook) do
      name "facebook"
      title "Facebook"
    end

    trait(:github) do
      name "github"
      title "GitHub"
    end

    trait(:counter_html) do
      name "counter_html"
      title "Counter Views"
    end

    trait(:counter_pdf) do
      name "counter_pdf"
      title "Counter Downloads"
    end

    trait(:pmc_html) do
      name "pmc_html"
      title "PubMed Central View Stats"
    end

    trait(:pmc_pdf) do
      name "pmc_pdf"
      title "PubMed Central Download Stats"
    end

    trait(:crossref) do
      name "crossref"
      title "CrossRef"
    end

    trait(:twitter) do
      name "twitter"
      title "Twitter"
    end

    initialize_with { Source.where(name: name).first_or_initialize }
  end
end
