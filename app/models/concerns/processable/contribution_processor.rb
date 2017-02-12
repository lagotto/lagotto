module Processable
  # Used in the Deposit model only.
  module ContributionProcessor
    extend ActiveSupport::Concern
    include Processable

    included do
      def update_contribution
        return true unless obj_id.present?

        result = Result.where(work_id: related_work_id,
                              source_id: source.id).first_or_create

        m = Month.where(work_id: related_work_id,
                        source_id: source.id,
                        result_id: result.id,
                        year: year,
                        month: month).first_or_create

        c = Contribution.where(contributor_id: contributor_id,
                               work_id: related_work_id,
                               source_id: source.id,
                               month_id: m.id).first_or_initialize

        # update all attributes
        c.assign_attributes(contributor_role_id: nil,
                            publisher_id: publisher.present? ? publisher.id : nil,
                            occurred_at: occurred_at)

        c.save!
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid => exception
        if exception.class == ActiveRecord::RecordNotUnique
          Contribution.where(contributor_id: contributor_id,
                                            work_id: related_work_id,
                                            source_id: source.id).first
        else
          handle_exception(exception, class_name: "contribution", id: "#{subj_id}/#{obj_id}/#{source_id}")
        end
      end
    end
  end
end
