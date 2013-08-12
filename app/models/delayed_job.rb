class DelayedJob < ActiveRecord::Base

  belongs_to :sources, :primary_key => "queue", :foreign_key => "name", :touch => true

end
