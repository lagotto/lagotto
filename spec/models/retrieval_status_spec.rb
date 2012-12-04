require 'spec_helper'

describe RetrievalStatus do
  
  it { should belong_to(:article) }
  it { should belong_to(:source) }
  it { should have_many(:retrieval_histories).dependent(:destroy) }
  
  it "stale_at should be publication date for unpublished articles" do
    unpublished_article = build(:retrieval_status, :unpublished)
    unpublished_article.stale_at.to_date.should eq(unpublished_article.article.published_on)
  end
  
  context "use stale_at" do  
    let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }
 
    it "stale_at should be a datetime" do
      retrieval_status.stale_at.should be_a_kind_of Time
    end
 
    it "stale_at should be in the future" do
      (retrieval_status.stale_at - Time.zone.now).should be > 0
    end
 
    it "stale_at should be after article publication date for published articles" do
      (retrieval_status.stale_at - retrieval_status.article.published_on.to_datetime).should be > 0
    end
  end
  
  context "staleness intervals" do
    
    it "published a day ago" do
      article = FactoryGirl.create(:article, :published_on => Time.zone.today - 1.day)
      retrieval_status = FactoryGirl.create(:retrieval_status, :article => article)
      duration = retrieval_status.source.staleness[0]
      (retrieval_status.stale_at - Time.zone.now).should be_between(duration, 1.1 * duration)
    end
    
    it "published 8 days ago" do
      article = FactoryGirl.create(:article, :published_on => Time.zone.today - 8.days)
      retrieval_status = FactoryGirl.create(:retrieval_status, :article => article)
      duration = retrieval_status.source.staleness[1]
      (retrieval_status.stale_at - Time.zone.now).should be_between(duration, 1.1 * duration)
    end
    
    it "published 32 days ago" do
      article = FactoryGirl.create(:article, :published_on => Time.zone.today - 32.days)
      retrieval_status = FactoryGirl.create(:retrieval_status, :article => article)
      duration = retrieval_status.source.staleness[2]
      (retrieval_status.stale_at - Time.zone.now).should be_between(duration, 1.1 * duration)
    end
    
    it "published 367 days ago" do
      article = FactoryGirl.create(:article, :published_on => Time.zone.today - 367.days)
      retrieval_status = FactoryGirl.create(:retrieval_status, :article => article)
      duration = retrieval_status.source.staleness[3]
      (retrieval_status.stale_at - Time.zone.now).should be_between(duration, 1.1 * duration)
    end
  end
end