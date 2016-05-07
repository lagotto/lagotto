module Processable
  module PublisherProcessor
    extend ActiveSupport::Concern
    include Processable

    included do
      def update_publisher
        item = from_publisher_csl(subj)
        p = Publisher.where(name: subj_id).first_or_initialize
        p.assign_attributes(item)
        p.save!
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => exception
        if exception.class == ActiveRecord::RecordNotUnique || exception.message.include?("has already been taken") || exception.class == ActiveRecord::StaleObjectError
           Publisher.using(:master).where(name: subj_id).first
        else
          handle_exception(exception, class_name: "publisher", id: subj_id)
        end
      end

      def delete_publisher
        Publisher.where(name: subj_id).destroy_all
      end

      # convert publisher CSL into format that the database understands
      # don't update nil values
      def from_publisher_csl(item)
        ra = cached_registration_agency(item.fetch("registration_agency_id", nil))

        { title: item.fetch("title", nil),
          other_names: item.fetch("other_names", nil),
          registration_agency_id: ra.present? ? ra.id : nil,
          checked_at: item.fetch("issued", Time.now.utc.iso8601),
          active: item.fetch("active", nil) }.compact
      end
    end
  end
end
