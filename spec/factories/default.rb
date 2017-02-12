FactoryGirl.define do

  factory :work, aliases: [:related_work] do
    sequence(:pid) { |n| "http://doi.org/10.1371/journal.pone.00000#{n}" }
    sequence(:doi) { |n| "10.1371/journal.pone.00000#{n}" }
    sequence(:pmid) { |n| "1897483#{n}" }
    sequence(:canonical_url) { |n| "http://journals.plos.org/plosone/article?id=10.1371/journal.pone.00000#{n}" }
    title 'Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web'
    year { Time.zone.now.to_date.year - 1 }
    month { Time.zone.now.to_date.month }
    day { Time.zone.now.to_date.day }
    issued_at { Time.zone.now }
    tracked true
    csl {{}}

    trait(:cited) { doi '10.1371/journal.pone.0000001' }
    trait(:uncited) { doi '10.1371/journal.pone.0000002' }
    trait(:not_publisher) { doi '10.1007/s00248-010-9734-2' }
    trait(:published_today) do
      year { Time.zone.now.to_date.year }
      month { Time.zone.now.to_date.month }
      day { Time.zone.now.to_date.day }
    end
    trait(:published_yesterday) do
      year { (Time.zone.now.to_date - 1.day).year }
      month { (Time.zone.now.to_date - 1.day).month }
      day { (Time.zone.now.to_date - 1.day).day }
    end

    factory :work_with_ids do
      sequence(:pmcid) { |n| "256885#{n}" }
      sequence(:wos) { |n| "00023796690000#{n}" }
      sequence(:scp) { |n| "3384533872#{n}" }
      sequence(:ark) { |n| "ark:/13030/m5br8st#{n}" }
    end
  end

  factory :deposit do
    uuid { SecureRandom.uuid }
    message_type "relation"
    prefix "10.1371"
    source_id "citeulike"
    source_token "citeulike_123"
    subj_id "http://www.citeulike.org/user/dbogartoit"
    subj {{ "pid"=>"http://www.citeulike.org/user/dbogartoit",
            "author"=>[{ "given"=>"dbogartoit" }],
            "title"=>"CiteULike bookmarks for user dbogartoit",
            "container-title"=>"CiteULike",
            "issued"=>"2006-06-13T16:14:19Z",
            "URL"=>"http://www.citeulike.org/user/dbogartoit",
            "type"=>"entry" }}
    obj_id "http://doi.org/10.1371/journal.pmed.0030186"
    relation_type_id "bookmarks"
    updated_at { Time.zone.now }
    occurred_at { Time.zone.now }

    factory :deposit_for_datacite_related do
      source_id "datacite_related"
      source_token "datacite_related_123"
      prefix "10.5061"
      subj_id "http://doi.org/10.5061/DRYAD.47SD5"
      subj nil
      obj_id "http://doi.org/10.5061/DRYAD.47SD5/1"
      relation_type_id "has_part"
      publisher_id "CDL.DRYAD"

      trait :with_works do
        association :work, pid: "http://doi.org/10.5061/DRYAD.47SD5"
        association :related_work, factory: :work, pid: "http://doi.org/10.5061/DRYAD.47SD5/1"
      end
    end

    factory :deposit_for_datacite_orcid do
      message_type "contribution"
      source_id "datacite_orcid"
      source_token "datacite_orcid_123"
      prefix "10.5061"
      subj_id "http://orcid.org/0000-0002-4133-2218"
      subj nil
      obj_id "http://doi.org/10.1594/PANGAEA.733793"
      publisher_id "TIB.PANGAEA"

      trait :with_contributor_and_work do
        #association :contributor, pid: "http://orcid.org/0000-0002-4133-2218"
        association :work, pid: "http://doi.org/10.1594/PANGAEA.733793"
      end
    end

    factory :deposit_for_datacite_github do
      source_id "datacite_github"
      source_token "datacite_github_123"
      prefix "10.5281"
      subj_id "http://doi.org/10.5281/ZENODO.16668"
      subj nil
      obj_id "https://github.com/konradjk/loftee/tree/v0.2.1-beta"
      relation_type_id "is_supplement_to"
      publisher_id "CERN.ZENODO"
    end

    factory :deposit_for_github do
      source_id "github"
      source_token "github_123"
      subj_id "https://github.com/2013/9"
      subj nil
      obj_id "https://github.com/ropensci/alm"
      relation_type_id "bookmarks"
      publisher_id "CERN.ZENODO"
      registration_agency_id "github"
      total 7
    end

    factory :deposit_for_facebook do
      source_id "facebook"
      source_token "facebook_123"
      subj_id "https://facebook.com/2013/9"
      subj nil
      obj_id "http://doi.org/10.1371/journal.pmed.0020124"
      relation_type_id "references"
      total 9972
    end

    factory :deposit_for_contributor do
      message_type "contribution"
      source_id "datacite_orcid"
      source_token "datacite_orcid_123"
      subj_id "http://orcid.org/0000-0002-0159-2197"
      obj_id nil

      trait :invalid_orcid do
        subj_id "555-1212"
      end
    end

    factory :deposit_for_publisher do
      message_type "publisher"
      source_id "datacite_datacentre"
      source_token "datacite_datacentre_123"
      subj_id "ANDS.CENTRE-1"
      subj {{ "name"=>"ANDS.CENTRE-1",
              "title"=>"Griffith University",
              "issued"=>"2006-06-13T16:14:19Z",
              "registration_agency_id"=>"datacite",
              "active"=>true }}

      trait :no_publisher_title do
        subj {{ "name"=>"ANDS.CENTRE-1",
                "issued"=>"2006-06-13T16:14:19Z",
                "registration_agency_id"=>"datacite",
                "active"=>true }}
      end
    end
  end
end
