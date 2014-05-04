require 'spec_helper'

describe History do

  let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }

  describe "error" do
    let(:data) { { error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/#{retrieval_status.article.doi_escaped}" } }
    subject { History.new(retrieval_status.id, data) }

    it "should have status error" do
      subject.status.should eq(:error)
    end

    it "should not create a retrieval_history record" do
      subject.retrieval_history.should be_nil
    end

    it "should respond to an error" do
      subject.to_hash.should eq(event_count: nil, previous_count: 50, retrieval_history_id: nil, update_interval: 30)
    end
  end

  describe "success no data" do
    let(:data) { { event_count: 0 } }
    subject { History.new(retrieval_status.id, data) }

    it "should have status success no data" do
      subject.status.should eq(:success_no_data)
    end

    it "should create a retrieval_history record" do
      subject.retrieval_history.event_count.should eq(data[:event_count])
    end

    #
    it "should respond to success with no data" do
      subject.to_hash.should eq(event_count: 0, previous_count: 50, retrieval_history_id: subject.retrieval_history.id, update_interval: 30)
    end
  end

  describe "success" do
    before(:each) { subject.put_alm_database }
    after(:each) { subject.delete_alm_database }

    let(:data) { { event_count: 25 } }
    subject { History.new(retrieval_status.id, data) }

    it "should have status success" do
      subject.status.should eq(:success)
    end

    it "should create a retrieval_history record" do
      subject.retrieval_history.event_count.should eq(data[:event_count])
    end

    it "should respond to success" do
      subject.to_hash.should eq(event_count: 25, previous_count: 50, retrieval_history_id: subject.retrieval_history.id, update_interval: 30)
    end

    # it "should store data in CouchDB" do
    #   subject.to_hash.should eq(event_count: 25, previous_count: 50, retrieval_history_id: subject.retrieval_history.id, update_interval: 30)
    #   subject.rs_rev.should be_nil
    #   subject.rh_rev.should be_nil
    # end
  end

end
