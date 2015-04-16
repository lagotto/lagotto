class Relationship < ActiveRecord::Base
  belongs_to :work
  belongs_to :related_work, class_name: "Work"
  belongs_to :relation_type
  belongs_to :source

  after_create :create_inverse_relationship

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
      if name.to_s[0] == "_"
        inverse_relation_name = name[1..-1]
      else
        inverse_relation_name = "_#{name}"
      end
      relation_type = RelationType.where(name: inverse_relation_name).first
      Relationship.where(work_id: related_work_id,
                         related_work_id: work_id,
                         source_id: source_id).first_or_create(
                           relation_type_id: inverse_relation_type.id)
    end
  end
end
