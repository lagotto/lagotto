require 'spec_helper'

describe Source do
  
  before do
    @source = FactoryGirl.create(:citeulike)
  end
  
  subject { @source }
  
  it { should belong_to(:group) }
  it { should have_many(:retrieval_statuses).dependent(:destroy) }
  
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:display_name) }
  it { should validate_presence_of(:workers) }
  it { should validate_numericality_of(:workers) }
  it { should ensure_inclusion_of(:workers).in_range(1..10).with_message("should be between 1 and 10") }
  it { should validate_presence_of(:timeout) }
  it { should validate_numericality_of(:timeout) }
  it { should ensure_inclusion_of(:timeout).in_range(1..3600).with_message("should be between 1 and 3600") }
  it { should validate_presence_of(:wait_time) }
  it { should validate_numericality_of(:wait_time) }
  it { should ensure_inclusion_of(:wait_time).in_range(1..3600).with_message("should be between 1 and 3600") }
  it { should validate_presence_of(:max_failed_queries) }
  it { should validate_numericality_of(:max_failed_queries) }
  it { should ensure_inclusion_of(:max_failed_queries).in_range(0..1000).with_message("should be between 0 and 1000") }
  it { should validate_presence_of(:max_failed_query_time_interval) }
  it { should validate_numericality_of(:max_failed_query_time_interval) }
  it { should ensure_inclusion_of(:max_failed_query_time_interval).in_range(0..864000).with_message("should be between 0 and 864000") }
  
  it "should have a job_batch_size attribute" do
    @source.should respond_to(:job_batch_size)
  end
  
  it "should have a batch_time_interval attribute" do
    @source.should respond_to(:batch_time_interval)
  end
  
  it "should have a staleness attribute" do
    @source.should respond_to(:staleness)
  end
  
  it "stale_at should depend on article age" do
    #@source.articles << build(:article, :published_on => 1.day.ago)
    #@source.articles << build(:article, :published_on => 2.months.ago)
    #@source.articles << build(:article, :published_on => 3.years.ago)
  end
  
  describe "use background jobs" do
    before(:each) do
      @article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0000001")
    end
    
    it "should queue an article" do
      retrieval_status = FactoryGirl.build(:retrieval_status, :source_id => @source.id, :article_id => @article.id)
      job = @source.queue_article_job(retrieval_status)
      worker = Delayed::Worker.new(:max_priority => nil, :min_priority => nil, :quiet => true)
      worker.work_off
    end
  
    it "should queue all stale articles" do
      retrieval_status = FactoryGirl.build(:retrieval_status, :source_id => @source.id, :article_id => @article.id, :scheduled_at => Time.zone.now - 1.day)
      job = @source.queue_article_jobs
      worker = Delayed::Worker.new(:max_priority => nil, :min_priority => nil, :quiet => true)
      worker.work_off
    end
  end
  
end