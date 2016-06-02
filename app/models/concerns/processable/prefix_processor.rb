module Processable
  module PrefixProcessor
    extend ActiveSupport::Concern
    include Processable

    included do
      def update_prefix
        items = from_prefix_csl(subj)
        Array(items).each do |item|
          begin
            p = Prefix.where(name: item[:prefix]).first_or_initialize
            p.assign_attributes(item)
            p.save!
            true
          rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => exception
            if exception.class == ActiveRecord::RecordNotUnique || exception.message.include?("has already been taken") || exception.class == ActiveRecord::StaleObjectError
              Prefix.using(:master).where(name: item[:prefix]).first
            else
              handle_exception(exception, class_name: "prefix", id: item[:prefix])
            end
          end
        end
      end

      # convert prefix CSL into format that the database understands
      # don't update nil values
      def from_prefix_csl(item)
        ra = cached_registration_agency(item.fetch("registration_agency_id", nil))
        publisher = cached_publisher(subj_id)

        Array(item.fetch("prefixes", nil)).map do |prefix|
          { name: prefix,
            publisher_id: publisher.present? ? publisher.id : nil,
            registration_agency_id: ra.present? ? ra.id : nil }.compact
        end
      end
    end
  end
end
