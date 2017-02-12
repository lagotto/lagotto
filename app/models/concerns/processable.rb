module Processable
  extend ActiveSupport::Concern

  included do
    def queue_deposit_job
      DepositJob.set(wait: 3.minutes).perform_later(self)
    end

    # Called as part of DepositJob.
    def process_data
      self.start

      if collect_data
        self.finish
      else
        self.error
      end
    end

    def collect_data
      case
      # when message_type == "publisher" && message_action == "delete" then delete_publisher
      # when message_type == "publisher" then update_publisher
      when message_type == "contribution" && message_action == "remove" then delete_contributor
      when message_type == "contribution" then update_contributions
      when message_type == "relation" && message_action == "remove" then delete_relation
      else update_relations
      end
    end

    # update in order, stop if an error occured
    def update_relations
      update_work &&
      update_related_work
    end

    def update_contributions
      update_related_work
    end

    def handle_exception(exception, options={})
      message = "#{exception.message} for #{options[:class_name]} #{options[:id]}"
      write_attribute(:error_messages, { options[:class_name] => exception.message })

      false
    end
  end
end
