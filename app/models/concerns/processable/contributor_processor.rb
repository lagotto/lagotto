module Processable
  module ContributorProcessor
    extend ActiveSupport::Concern
    include Processable

    included do
      def update_contributor
        self.contributor = Contributor.where(pid: subj_id).first_or_initialize

        # save deposit and contributor (thanks to autosave option) to the database
        self.contributor.save!
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique, ActiveRecord::StaleObjectError => exception
        if exception.class == ActiveRecord::RecordNotUnique || exception.message.include?("has already been taken") || exception.class == ActiveRecord::StaleObjectError
          contributor = Contributor.using(:master).where(pid: subj_id).first
        else
          handle_exception(exception, class_name: "contributor", id: subj_id, target_url: subj_id)
        end
      end

      def update_contribution
        return true unless obj_id.present?

        c = Contribution.where(contributor_id: contributor_id,
                               work_id: related_work_id).first_or_initialize

        # update all attributes
        c.assign_attributes(source_id: source.present? ? source.id : nil,
                            publisher_id: publisher.present? ? publisher.id : nil)

        c.save!
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => exception
        handle_exception(exception, class_name: "contribution", id: "#{subj_id}/#{obj_id}/#{source_id}")
      end
    end
  end
end
