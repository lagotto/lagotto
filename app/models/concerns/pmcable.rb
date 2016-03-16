module Pmcable
  extend ActiveSupport::Concern

  included do
    def get_data(options={})
      query_url = get_query_url(options)
      return query_url.extend Hashie::Extensions::DeepFetch if query_url.is_a?(Hash)

      result = get_result(query_url, options)
      total = (result.fetch("hitCount", nil)).to_i

      if total > rows
        # walk through paginated results
        total_pages = (total.to_f / rows).ceil

        (2..total_pages).each do |page|
          options[:page] = page
          query_url = get_query_url(options)
          paged_result = get_result(query_url, options)
          result["#{result_key}List"][result_key] = result["#{result_key}List"][result_key] | paged_result.fetch("#{result_key}List", {}).fetch(result_key, [])
        end
      end

      # extend hash fetch method to nested hashes
      result.extend Hashie::Extensions::DeepFetch
    end

    def parse_data(result, options={})
      return result if result[:error] || result["#{result_key}List"].nil?

      work = Work.where(id: options.fetch(:work_id, nil)).first

      get_relations_with_related_works(result, work)
    end

    def get_relations_with_related_works(result, work)
      result.fetch("#{result_key}List", {}).fetch(result_key, []).map do |item|
        pmid = item.fetch(pmid_key, nil)
        ids = get_persistent_identifiers(pmid, "pmid")
        ids = {} unless ids.is_a?(Hash)
        doi = ids.fetch("doi", nil)
        pmcid = ids.fetch("pmcid", nil)
        pmcid = pmcid[3..-1] if pmcid
        author_string = item.fetch("authorString", "").chomp(".")

        if doi.present?
          registration_agency = "crossref"
          pid = doi_as_url(doi)
        else
          registration_agency = "pubmed"
          pid = pmid_as_url(pmid)
        end

        { relation: { "subj_id" => pid,
                      "obj_id" => work.pid,
                      "relation_type_id" => "cites",
                      "source_id" => source_id },
          subj: { "pid" => pid,
                  "author" => get_authors(author_string.split(", "), reversed: true),
                  "title" => item.fetch("title", "").chomp("."),
                  "container-title" => item.fetch(container_title_key, nil),
                  "issued" => get_date_parts_from_parts(item.fetch("pubYear", nil)),
                  "DOI" => doi,
                  "PMID" => pmid,
                  "PMCID" => pmcid,
                  "type" => "article-journal",
                  "registration_agency" => registration_agency,
                  "tracked" => tracked }}
      end
    end
  end
end
