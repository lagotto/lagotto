module Processable
  # Used in the Deposit model only. Updates attached subject and object works.
  module WorkProcessor
    extend ActiveSupport::Concern
    include Processable

    included do
      def update_work
        return true if registration_agency_id == ENV['RA'] ||
          doi_from_url(subj_id) && get_doi_ra(doi_from_url(subj_id)).fetch(:id, nil) == ENV['RA']

        pid = normalize_pid(subj_id)
        item = from_csl(subj)

        # initialize work if it doesn't exist
        self.work = Work.where(pid: pid).first_or_initialize

        # update all attributes
        self.work.assign_attributes(item)

        # save deposit and work (thanks to autosave option) to the database
        self.save!
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique, ActiveRecord::StaleObjectError, ActiveRecord::StatementInvalid => exception
        if exception.class == ActiveRecord::RecordNotUnique || exception.message.include?("has already been taken") || exception.class == ActiveRecord::StaleObjectError
          self.work = Work.where(pid: pid).first
        else
          handle_exception(exception, class_name: "work", id: pid, target_url: pid)
        end
      end

      def update_related_work
        return true if obj_id.blank? ||
          registration_agency_id == ENV['RA'] ||
          doi_from_url(subj_id) && get_doi_ra(doi_from_url(subj_id)).fetch(:id, nil) == ENV['RA']


        pid = normalize_pid(obj_id)
        item = from_csl(obj)

        # initialize related_work if it doesn't exist
        self.related_work = Work.where(pid: pid).first_or_initialize

        # update all attributes
        self.related_work.assign_attributes(item)

        # save deposit and related_work (thanks to autosave option) to the database
        self.save!
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique, ActiveRecord::StaleObjectError, ActiveRecord::StatementInvalid => exception
        if exception.class == ActiveRecord::RecordNotUnique || exception.message.include?("has already been taken") || exception.class == ActiveRecord::StaleObjectError
          self.related_work = Work.where(pid: pid).first
        else
          handle_exception(exception, class_name: "related_work", id: pid, target_url: pid)
        end
      end

      # convert CSL into format that the database understands
      # don't update nil values
      def from_csl(item)
        issued_at = item.fetch("issued", nil)

        if item["published"].present?
          year, month, day = get_year_month_day(item.fetch("published", nil))
        else
          year, month, day = get_year_month_day(issued_at)
        end

        csl = { "author" => item.fetch("author", []),
                "container-title" => item.fetch("container-title", nil),
                "volume" => item.fetch("volume", nil),
                "page" => item.fetch("page", nil),
                "issue" => item.fetch("issue", nil) }.compact

        { doi: item.fetch("DOI", nil),
          pmid: item.fetch("PMID", nil),
          pmcid: item.fetch("PMCID", nil),
          arxiv: item.fetch("arxiv", nil),
          ark: item.fetch("ark", nil),
          canonical_url: item.fetch("URL", nil),
          title: item.fetch("title", nil),
          year: year,
          month: month,
          day: day,
          issued_at: item.fetch("issued", nil),
          tracked: item.fetch("tracked", nil),
          resource_type_id: item.fetch("resource_type_id", nil),
          resource_type: item.fetch("resource_type", nil),
          publisher_id: item.fetch("publisher_id", nil),
          registration_agency_id: item.fetch("registration_agency_id", nil),
          csl: csl }.compact
      end
    end
  end
end
