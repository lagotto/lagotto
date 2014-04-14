class DelayedJob < ActiveRecord::Base
  belongs_to :source, :primary_key => "queue", :foreign_key => "name", :touch => true
end
