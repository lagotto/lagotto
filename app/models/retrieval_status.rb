class RetrievalStatus < ActiveRecord::Base
  belongs_to :article
  belongs_to :source
end
