module Datacitable
  extend ActiveSupport::Concern

  included do
    def get_query_url(options={})
      offset = options[:offset].to_i
      rows = options[:rows].presence || job_batch_size
      from_date = options[:from_date].presence || (Time.zone.now.to_date - 1.day).iso8601
      until_date = options[:until_date].presence || Time.zone.now.to_date.iso8601

      updated = "updated:[#{from_date}T00:00:00Z TO #{until_date}T23:59:59Z]"
      fq = "#{updated} AND has_metadata:true AND is_active:true"
      fq += " AND #{datacentre_symbol}" if datacentre_symbol

      params = { q: q,
                 start: offset,
                 rows: rows,
                 fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre_symbol,relatedIdentifier,nameIdentifier,xml,minted,updated",
                 fq: fq,
                 wt: "json" }
      url +  URI.encode_www_form(params)
    end

    def get_total(options={})
      query_url = get_query_url(options.merge(rows: 0))
      result = get_result(query_url, options)
      result.fetch("response", {}).fetch("numFound", 0)
    end

    def queue_jobs(options={})
      return 0 unless active?

      unless options[:all]
        return 0 unless stale?
      end

      total = get_total(options)

      if total > 0
        # walk through paginated results
        total_pages = (total.to_f / job_batch_size).ceil

        (0...total_pages).each do |page|
          options[:offset] = page * job_batch_size
          AgentJob.set(queue: queue, wait_until: schedule_at).perform_later(self, options)
        end

        schedule_next_run
      end

      # return number of works queued
      total
    end

    def get_data(options={})
      query_url = get_query_url(options)
      get_result(query_url, options)
    end

    def parse_data(result, options={})
      result = { error: "No hash returned." } unless result.is_a?(Hash)
      return [result] if result[:error]

      items = result.fetch('response', {}).fetch('docs', nil)
      get_relations_with_related_works(items)
    end

    def get_relations_with_related_works(items)
      Array(items).reduce([]) do |sum, item|
        doi = item.fetch("doi", nil)
        prefix = doi[/^10\.\d{4,5}/]
        pid = doi_as_url(doi)
        type = item.fetch("resourceTypeGeneral", nil)
        type = DATACITE_TYPE_TRANSLATIONS[type] if type
        publisher_id = item.fetch("datacentre_symbol", nil)

        xml = Base64.decode64(item.fetch('xml', "PGhzaD48L2hzaD4=\n"))
        xml = Hash.from_xml(xml).fetch("resource", {})
        authors = xml.fetch("creators", {}).fetch("creator", [])
        authors = [authors] if authors.is_a?(Hash)

        subj = { "pid" => pid,
                 "DOI" => doi,
                 "author" => get_hashed_authors(authors),
                 "title" => item.fetch("title", []).first,
                 "container-title" => item.fetch("publisher", nil),
                 "published" => item.fetch("publicationYear", nil),
                 "issued" => item.fetch("minted", nil),
                 "publisher_id" => publisher_id,
                 "registration_agency_id" => "datacite",
                 "tracked" => true,
                 "type" => type }

        related_doi_identifiers = item.fetch('relatedIdentifier', []).select { |id| id =~ /:DOI:.+/ }
        sum += get_doi_relations(subj, related_doi_identifiers)

        related_github_identifiers = item.fetch('relatedIdentifier', []).select { |id| id =~ /:URL:https:\/\/github.com.+/ }
        sum += get_github_relations(subj, related_github_identifiers)

        name_identifiers = item.fetch('nameIdentifier', []).select { |id| id =~ /^ORCID:.+/ }
        sum += get_contributions(subj, name_identifiers)

        if source_id == "datacite_import"
          sum += [{ prefix: prefix,
                    relation: { "subj_id" => subj["pid"],
                                "source_id" => source_id,
                                "publisher_id" => subj["publisher_id"],
                                "occurred_at" => subj["issued"] },
                    subj: subj }]
        end

        sum
      end
    end

    def get_github_relations(subj, items)
      prefix = subj["DOI"][/^10\.\d{4,5}/]

      Array(items).reduce([]) do |sum, item|
        raw_relation_type, _related_identifier_type, related_identifier = item.split(':', 3)

        # find relation_type, default to "is_referenced_by" otherwise
        relation_type = cached_relation_type(raw_relation_type.underscore)
        relation_type_id = relation_type.present? ? relation_type.name : 'is_referenced_by'

        # get parent repo
        # code from https://github.com/octokit/octokit.rb/blob/master/lib/octokit/repository.rb
        related_identifier = PostRank::URI.clean(related_identifier)
        github_hash = github_from_url(related_identifier)
        owner_url = github_as_owner_url(github_hash)
        repo_url = github_as_repo_url(github_hash)

        sum << { prefix: prefix,
                 relation: { "subj_id" => subj["pid"],
                             "obj_id" => related_identifier,
                             "relation_type_id" => relation_type_id,
                             "source_id" => source_id,
                             "publisher_id" => subj["publisher_id"],
                             "registration_agency_id" => "github",
                             "occurred_at" => subj["issued"] },
                 subj: subj }

        # if relatedIdentifier is release URL rather than repo URL
        if related_identifier != repo_url
          sum << { relation: { "subj_id" => related_identifier,
                               "obj_id" => repo_url,
                               "relation_type_id" => "is_part_of",
                               "source_id" => source_id,
                               "publisher_id" => "github",
                               "registration_agency_id" => "github" } }
        end

        sum << {  message_type: "contribution",
                  relation: { "subj_id" => owner_url,
                              "obj_id" => repo_url,
                              "source_id" => "github_contributor",
                              "registration_agency_id" => "github" }}
      end
    end

    def get_doi_relations(subj, items)
      prefix = subj["DOI"][/^10\.\d{4,5}/]

      Array(items).reduce([]) do |sum, item|
        raw_relation_type, _related_identifier_type, related_identifier = item.split(':', 3)
        doi = related_identifier.strip.upcase
        registration_agency = get_doi_ra(doi)

        if source_id == "datacite_crossref" && registration_agency[:name] == "datacite"
          sum
        else
          _source_id = registration_agency[:name] == "crossref" ? "datacite_crossref" : "datacite_related"
          pid = doi_as_url(doi)

          # find relation_type, default to "is_referenced_by" otherwise
          relation_type = cached_relation_type(raw_relation_type.underscore)
          relation_type_id = relation_type.present? ? relation_type.name : 'is_referenced_by'

          sum << { prefix: prefix,
                   relation: { "subj_id" => subj["pid"],
                               "obj_id" => pid,
                               "relation_type_id" => relation_type_id,
                               "source_id" => _source_id,
                               "publisher_id" => subj["publisher_id"],
                               "registration_agency_id" => registration_agency[:name],
                               "occurred_at" => subj["issued"] },
                   subj: subj }
        end
      end
    end

    # we are flipping subj and obj for contributions
    def get_contributions(obj, items)
      prefix = obj["DOI"][/^10\.\d{4,5}/]

      Array(items).reduce([]) do |sum, item|
        orcid = item.split(':', 2).last
        orcid = validate_orcid(orcid)

        return sum if orcid.nil?

        sum << { prefix: prefix,
                 message_type: "contribution",
                 relation: { "subj_id" => orcid_as_url(orcid),
                             "obj_id" => obj["pid"],
                             "source_id" => source_id,
                             "publisher_id" => obj["publisher_id"],
                             "registration_agency_id" => "datacite",
                             "occurred_at" => obj["issued"] },
                 obj: obj }
      end
    end

    def config_fields
      [:url, :personal_access_token, :only_publishers]
    end

    def url
      "http://search.datacite.org/api?"
    end

    # More info at https://github.com/blog/1509-personal-api-tokens
    def personal_access_token
      config.personal_access_token
    end

    def personal_access_token=(value)
      config.personal_access_token = value
    end

    def datacentre_symbol
      if only_publishers
        member = Publisher.active.joins(:registration_agency).where("registration_agencies.name = ?", "datacite").pluck(:name)
        member.blank? ? nil : "datacentre_symbol:" + member.join("+OR+")
      end
    end

    def cron_line
      config.cron_line || "40 18 * * *"
    end

    def timeout
      config.timeout || 120
    end

    def job_batch_size
      config.job_batch_size || 1000
    end

    def tracked
      config.tracked || true
    end
  end
end
