FactoryGirl.define do
  factory :source do
    name "citeulike"
    title "CiteULike"
    active true

    trait(:datacite_related) do
      name "datacite_related"
      title "DataCite Related"
    end

    trait(:datacite_github) do
      name "datacite_github"
      title "DataCite Github"
    end

    trait(:datacite_orcid) do
      name "datacite_orcid"
      title "DataCite ORCID"
    end

    trait(:datacite_datacentre) do
      name "datacite_datacentre"
      title "DataCite Data Centres"
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
