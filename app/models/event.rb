class Event < ActiveRecord::Base
  belongs_to :work, :primary_key => "parent_work_id"
end
