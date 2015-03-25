class Event < ActiveRecord::Base
  belongs_to :work
  belongs_to :citation, :class_name => "Work"
end
