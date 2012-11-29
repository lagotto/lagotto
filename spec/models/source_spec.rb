require 'spec_helper'

describe Source do
  
  let(:source) { FactoryGirl.create(:source) }
  
  subject { source }
  
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
    source.should respond_to(:job_batch_size)
  end
  
  it "should have a batch_time_interval attribute" do
    source.should respond_to(:batch_time_interval)
  end
  
  it "should have a staleness attribute" do
    source.should respond_to(:staleness)
  end
  
  it "stale_at should depend on article age" do
    #@source.articles << build(:article, :published_on => 1.day.ago)
    #@source.articles << build(:article, :published_on => 2.months.ago)
    #@source.articles << build(:article, :published_on => 3.years.ago)
  end
  
  context "use background jobs" do
    let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :scheduled_at => Time.zone.now - 1.day) }
    let(:source_job) { SourceJob.new([retrieval_status.id], retrieval_status.source.id) }
    
    it "queue all articles" do
      #source.queue_all_articles
      #source.get_queued_job_count.should eq(1)
    end
    
    it "queue articles" do
      #source.queue_articles
      #source.get_queued_job_count.should eq(1)
    end
    
    it "queue article jobs" do
    end
    
    it "queue article job" do
      #source.queue_article_job(retrieval_status)
      #worker = Delayed::Worker.new(:max_priority => nil, :min_priority => nil, :quiet => true)
      #worker.work_off
      #worker.should eq(2)
    end
  
    it "should queue all stale articles" do
      #job = source.queue_article_jobs
      #worker = Delayed::Worker.new(:max_priority => nil, :min_priority => nil, :quiet => true)
      #worker.work_off
    end
  end
end