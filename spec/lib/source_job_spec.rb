require 'spec_helper'

describe SourceJob do

  let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }
  let(:source) { FactoryGirl.create(:source) }
  let(:rs_id) { "#{retrieval_status.source.name}:#{retrieval_status.article.doi_escaped}" }
  let(:job) { FactoryGirl.create(:delayed_job) }

  subject { SourceJob.new([retrieval_status.id], source.id) }

  before(:each) { subject.put_alm_database }
  after(:each) { subject.delete_alm_database }

  context "perform get data" do
    it "should perform and get DelayedJob timeout error" do
      subject.should_receive(:perform_get_data).and_raise(Timeout::Error)
      expect { subject.perform }.to raise_error(Timeout::Error)

      # Alert.count.should == 1
      # alert = Alert.first
      # alert.class_name.should eq("Timeout::Error")
      # alert.message.should eq("SourceJob timeout error for CiteULike")
      # alert.status.should == 408
      # alert.source_id.should == source.id
    end

    it "should perform and get data" do
      stub = stub_request(:get, source.get_query_url(retrieval_status.article)).to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
      result = subject.perform_get_data(retrieval_status)
      result[:event_count].should eq(25)
      rh_id = result[:retrieval_history_id]

      rs_result = subject.get_alm_data(rs_id)
      rs_result.should include("source" => retrieval_status.source.name,
                               "doi" => retrieval_status.article.doi,
                               "doc_type" => "current",
                               "_id" =>  "#{retrieval_status.source.name}:#{retrieval_status.article.doi}")
      rh_result = subject.get_alm_data(rh_id)
      rh_result.should include("source" => retrieval_status.source.name,
                               "doi" => retrieval_status.article.doi,
                               "doc_type" => "history",
                               "_id" => "#{rh_id}")
    end

    it "should perform and update CouchDB" do
      stub = stub_request(:get, source.get_query_url(retrieval_status.article)).to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
      result = subject.perform_get_data(retrieval_status)
      rh_id = result[:retrieval_history_id]

      rs_result = subject.get_alm_data(rs_id)
      rs_result.should include("source" => retrieval_status.source.name,
                               "doi" => retrieval_status.article.doi,
                               "doc_type" => "current",
                               "_id" => "#{retrieval_status.source.name}:#{retrieval_status.article.doi}")
      rh_result = subject.get_alm_data(rh_id)
      rh_result.should include("source" => retrieval_status.source.name,
                               "doi" => retrieval_status.article.doi,
                               "doc_type" => "history",
                               "_id" => "#{rh_id}")

      new_result = subject.perform_get_data(retrieval_status)
      new_rh_id = new_result[:retrieval_history_id]
      new_rh_id.should_not eq(rh_id)

      new_rs_result = subject.get_alm_data(rs_id)
      new_rs_result.should include("source" => retrieval_status.source.name,
                                   "doi" => retrieval_status.article.doi,
                                   "doc_type" => "current",
                                   "_id" => "#{retrieval_status.source.name}:#{retrieval_status.article.doi}")
      new_rs_result["_rev"].should_not be_nil
      new_rs_result["_rev"].should_not eq(rs_result["_rev"])

      new_rh_result = subject.get_alm_data(new_rh_id)
      new_rh_result.should include("source" => retrieval_status.source.name,
                                   "doi" => retrieval_status.article.doi,
                                   "doc_type" => "history",
                                   "_id" => "#{new_rh_id}")
      new_rh_result["_rev"].should_not be_nil
      new_rh_result["_id"].should_not eq(rh_result["_id"])
    end

    it "should perform and get no data" do
      stub = stub_request(:get, source.get_query_url(retrieval_status.article)).to_return(:body => File.read(fixture_path + 'citeulike_nil.xml'), :status => 200)
      result = subject.perform_get_data(retrieval_status)
      result[:event_count].should eq(0)
    end

    it "should perform and get skipped" do
      retrieval_status = FactoryGirl.create(:retrieval_status, :missing_mendeley)
      scheduled_at = retrieval_status.scheduled_at
      stub = stub_request(:get, retrieval_status.source.get_query_url(retrieval_status.article, "doi")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      stub_pubmed = stub_request(:get, retrieval_status.source.get_query_url(retrieval_status.article, "pmid")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      stub_title = stub_request(:get, retrieval_status.source.get_query_url(retrieval_status.article, "title")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      result = subject.perform_get_data(retrieval_status)
      result[:event_count].should eq(0)
      result[:retrieval_history_id].should be_nil
    end

    it "should perform and get error" do
      scheduled_at = retrieval_status.scheduled_at
      stub = stub_request(:get, source.get_query_url(retrieval_status.article)).to_return(:status => [408])
      result = subject.perform_get_data(retrieval_status)
      result[:event_count].should be_nil
      result[:retrieval_history_id].should be_nil

      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == source.id
    end
  end

  context "error" do
    it "should create an alert on error" do
      exception = StandardError.new
      subject.error(job, exception)

      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("StandardError")
      alert.source_id.should == source.id
    end

    it "should not create an alert if source is not in working state" do
      exception = SourceInactiveError.new
      subject.error(job, exception)

      Alert.count.should == 0
    end

    it "should not create an alert if not enough workers available for source" do
      exception = NotEnoughWorkersError.new
      subject.error(job, exception)

      Alert.count.should == 0
    end
  end

  context "failure" do
    it "should create an alert on failure" do
      subject.failure(job)

      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("DelayedJobError")
      alert.source_id.should == source.id
    end
  end

  context "after" do
    # TODO: needs further work
    it "should clean up after the job" do
      subject.after(job)

      source.should be_waiting
    end
  end

  context "reschedule jobs" do
    before(:each) { Time.stub(:now).and_return(Time.mktime(2013, 9, 5)) }
    let(:time) { Time.now - 30.minutes }

    it "should reschedule a job after 0 attempts" do
      subject.reschedule_at(time, 0).should eq(time + 1.minute)
    end

    it "should reschedule a job after 6 attempts" do
      subject.reschedule_at(time, 6).should eq(time + 5.minutes)
    end

    it "should reschedule a job after 11 attempts" do
      subject.reschedule_at(time, 11).should eq(time + 30.minutes)
    end

    it "should reschedule a job after 16 attempts" do
      subject.reschedule_at(time, 16).should eq(time + 1.hour)
    end

    it "should reschedule a job after 21 attempts" do
      subject.reschedule_at(time, 21).should eq(time + 3.hours)
    end
  end
end
