class RetrievalStatus < ActiveRecord::Base
  belongs_to :article
  belongs_to :source
  has_many :retrieval_histories, :dependent => :destroy
end
