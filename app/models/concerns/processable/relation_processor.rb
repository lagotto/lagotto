module Processable
  module RelationProcessor
    extend ActiveSupport::Concern
    include Processable

    included do
      def update_relation
        result = Result.where(work_id: related_work_id,
                              source_id: source.id).first_or_create

        m = Month.where(work_id: related_work_id,
                        source_id: source.id,
                        result_id: result.id,
                        year: year,
                        month: month).first_or_create

        r = Relation.where(work_id: work_id,
                           related_work_id: related_work_id,
                           source_id: source.id,
                           month_id: m.id).first_or_initialize

        # update all attributes
        r.assign_attributes(relation_type_id: relation_type.present? ? relation_type.id : nil,
                            publisher_id: publisher.present? ? publisher.id : nil,
                            total: adjusted_total(work_id),
                            occurred_at: occurred_at)
        r.save!
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => exception
        if exception.class == ActiveRecord::RecordNotUnique
          Relation.using(:master).where(work_id: work_id,
                                        related_work_id: related_work_id,
                                        source_id: source.id).first
        else
          handle_exception(exception, class_name: "relation", id: "#{subj_id}/#{obj_id}/#{source_id}")
        end
      end

      def update_inv_relation
        r = Relation.where(work_id: related_work_id,
                           related_work_id: work_id,
                           source_id: source.id).first_or_initialize

        # update all attributes, return saved inv_relation
        r.assign_attributes(relation_type_id: inv_relation_type.present? ? inv_relation_type.id : nil,
                            publisher_id: publisher.present? ? publisher.id : nil,
                            total: adjusted_total(related_work_id),
                            occurred_at: occurred_at,
                            implicit: true)
        r.save!
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => exception
        if exception.class == ActiveRecord::RecordNotUnique
          Relation.using(:master).where(work_id: related_work_id,
                                        related_work_id: work_id,
                                        source_id: source.id).first
        else
          handle_exception(exception, class_name: "inv_relation", id: "#{subj_id}/#{obj_id}/#{source_id}")
        end
      end

      def delete_relation
        work = Work.where(pid: subj_id).first
        related_work = Work.where(pid: obj_id).first
        source = Source.where(name: source_id).first

        return nil unless work.present? && related_work.present? && source.present?

        Relation.where(work_id: work.id, related_work_id: related_work.id, source_id: source.id).destroy_all
      end

      def adjusted_total(w_id)
        if source.present? && source.cumulative
          total - get_total_previous_month(w_id)
        else
          total
        end
      end

      def get_total_previous_month(w_id)
        return 0 unless w_id.present? && relation_type.present? && source.present?

        relation = Relation.where(work_id: w_id)
                           .where(source_id: source.id)
                           .where(relation_type_id: relation_type.id)
                           .where("occurred_at < ?", Time.zone.now.beginning_of_month)
                           .order("occurred_at DESC").first

        return 0 unless relation.present?

        return relation.total
      end
    end
  end
end
