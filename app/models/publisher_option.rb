class PublisherOption < ActiveRecord::Base
  belongs_to :publisher
  belongs_to :source
end
