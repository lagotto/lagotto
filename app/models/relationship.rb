class Relationship < ActiveRecord::Base
  belongs_to :work
  belongs_to :related_work, class_name: "Work"
  belongs_to :relation_type
  belongs_to :source

  after_create :create_inverse_relationship

  scope :similar, ->(work_id) { where("total > ?", 0) }

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "#{id}/#{timestamp}"
  end

  private

  def create_inverse_relationship
    if relation_type.name == "is_identical_to"
      # don't create inverse relationship, but set level to 0
      self.level = 0
    else
      if relation_type.name.to_s[0] == "_"
        inverse_relation_name = relation_type.name[1..-1]
      else
        inverse_relation_name = "_#{relation_type.name}"
      end
      inverse_relation_type = RelationType.where(name: inverse_relation_name).first
      inverse_relation_type_id = inverse_relation_type ? inverse_relation_type.id : nil
      return unless related_work_id.present? && work_id.present? && source_id.present? && inverse_relation_type_id.present?

      Relationship.where(work_id: related_work_id,
                         related_work_id: work_id,
                         source_id: source_id).first_or_create(
                           relation_type_id: inverse_relation_type_id)
    end
  end
end
