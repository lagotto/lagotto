require 'spec_helper'

describe RetrievalStatus do
  
  it { should belong_to(:article) }
  it { should belong_to(:source) }
  it { should have_many(:retrieval_histories).dependent(:destroy) }
  
  it "stale_at should be publication date for unpublished articles" do
    unpublished_article = build(:retrieval_status, :unpublished)
    unpublished_article.stale_at.to_date.should eq(unpublished_article.article.published_on)
  end
  
  describe "use stale_at" do  
    before do
      @retrieval_status = FactoryGirl.build(:retrieval_status)
    end
 
   it "stale_at should be a datetime" do
     @retrieval_status.stale_at.should be_a_kind_of Time
   end
 
   it "stale_at should be in the future" do
     (@retrieval_status.stale_at - Time.zone.now).should be > 0
   end
 
   it "stale_at should be after article publication date for published articles" do
     (@retrieval_status.stale_at - @retrieval_status.article.published_on.to_datetime).should be > 0
   end
 end

end

