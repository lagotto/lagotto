module Crossrefable
  extend ActiveSupport::Concern

  included do
    def get_query_url(options={})
      offset = options[:offset].to_i
      rows = options[:rows].presence || job_batch_size
      from_date = options[:from_date].presence || (Time.zone.now.to_date - 1.day).iso8601
      until_date = options[:until_date].presence || Time.zone.now.to_date.iso8601

      filter = q
      filter += "from-update-date:#{from_date}"
      filter += ",until-update-date:#{until_date}"
      filter += member if member.present?

      if sample.to_i > 0
        params = { filter: filter, sample: sample }
      else
        params = { filter: filter, offset: offset, rows: rows }
      end
      url + params.to_query
    end

    def get_total(options={})
      query_url = get_query_url(options.merge(rows: 0))
      result = get_result(query_url, options.merge(host: true))
      result.fetch('message', {}).fetch('total-results', 0)
    end

    def queue_jobs(options={})
      return 0 unless active?

      unless options[:all]
        return 0 unless stale?
      end

      query_url = get_query_url(options.merge(rows: 0))
      result = get_result(query_url, options.merge(host: true))
      total = result.fetch("message", {}).fetch("total-results", 0)

      if total > 0
        # walk through paginated results
        total = sample if sample.present?
        total_pages = (total.to_f / job_batch_size).ceil

        (0...total_pages).each do |page|
          options[:offset] = page * job_batch_size
          options[:rows] = sample if sample && sample < (page + 1) * job_batch_size
          AgentJob.set(queue: queue, wait_until: schedule_at).perform_later(self, options)
        end

        schedule_next_run
      end

      # return number of works queued
      total
    end

    def get_data(options={})
      query_url = get_query_url(options)
      get_result(query_url, options.merge(host: true))
    end

    def parse_data(result, options={})
      result = { error: "No hash returned." } unless result.is_a?(Hash)
      return [result] if result[:error] || result.fetch('status', nil) != "ok"

      items = result.fetch('message', {}).fetch('items', nil)
      get_relations_with_related_works(items)
    end

    def get_relations_with_related_works(items)
      Array(items).reduce([]) do |sum, item|
        date_parts = item.fetch("issued", {}).fetch("date-parts", []).first
        year, month, day = date_parts[0], date_parts[1], date_parts[2]

        # use date indexed if date issued is in the future
        if year.nil? || Date.new(*date_parts) > Time.zone.now.to_date
          published = get_date_from_parts(year, month, day)

          date_parts = item.fetch("indexed", {}).fetch("date-parts", []).first
          issued = get_date_from_parts(*date_parts)
        else
          published = nil
          issued = get_date_from_parts(year, month, day)
        end

        author = item.fetch("author", []).map { |a| a.except("affiliation") }

        title = case item["title"].length
                when 0 then nil
                when 1 then item["title"][0]
                else item["title"][0].presence || item["title"][1]
                end

        if title.blank? && !TYPES_WITH_TITLE.include?(item["type"])
          title = item["container-title"][0].presence || "No title"
        end

        type = item.fetch("type", nil)
        type = CROSSREF_TYPE_TRANSLATIONS[type] if type
        doi = item.fetch("DOI", nil)

        subj = { "pid" => doi_as_url(doi),
                 "author" => author,
                 "container-title" => item.fetch("container-title", []).first,
                 "title" => title,
                 "published" => published,
                 "issued" => issued,
                 "DOI" => doi,
                 "publisher_id" => item.fetch("member", "")[30..-1],
                 "volume" => item.fetch("volume", nil),
                 "issue" => item.fetch("issue", nil),
                 "page" => item.fetch("page", nil),
                 "type" => type,
                 "registration_agency_id" => "crossref",
                 "tracked" => true }

        authors_with_orcid = item.fetch('author', []).select { |author| author["ORCID"].present? }
        sum += get_contributions(subj, authors_with_orcid)

        if source_id == "crossref_import"
          prefix = doi[/^10\.\d{4,5}/]

          sum += [{ prefix: prefix,
                    relation: { "subj_id" => subj["pid"],
                                "source_id" => source_id,
                                "publisher_id" => subj["publisher_id"] },
                    subj: subj }]
        end

        sum
      end
    end

    def get_contributions(obj, items)
      prefix = obj["DOI"][/^10\.\d{4,5}/]

      Array(items).reduce([]) do |sum, item|
        orcid = item.fetch('ORCID', nil)
        orcid = validate_orcid(orcid)

        return sum if orcid.nil?

        sum << { prefix: prefix,
                 message_type: "contribution",
                 relation: { "subj_id" => orcid_as_url(orcid),
                             "obj_id" => obj["pid"],
                             "source_id" => source_id,
                             "publisher_id" => obj["publisher_id"] },
                 obj: obj }
      end
    end

    def config_fields
      [:url, :sample, :only_publishers]
    end

    def member
      if only_publishers
        member = Publisher.active.joins(:registration_agency).where("registration_agencies.name = ?", "crossref").pluck(:name)
        member.blank? ? nil : member.reduce("") { |sum, m| sum + ",member:#{m}" } if member.present?
      end
    end

    def url
      "http://api.crossref.org/works?"
    end

    def sample
      config.sample
    end

    def sample=(value)
      config.sample = value.to_i
    end

    def job_batch_size
      config.job_batch_size || 1000
    end
  end
end
