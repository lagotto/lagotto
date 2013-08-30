# encoding: UTF-8

require 'spec_helper'

describe Filter do

  subject { Filter }

  it { should respond_to(:all) }
  it { should respond_to(:last_id) }
  it { should respond_to(:decreasing) }
  it { should respond_to(:increasing) }
  it { should respond_to(:slow) }
  it { should respond_to(:not_updated) }
  it { should respond_to(:resolve) }
  it { should respond_to(:raise_errors) }

  context "API responses" do
    before do
      @api_responses = FactoryGirl.create_list(:api_response, 3, event_count: 1050, duration: 16000)
      @id = @api_responses.last.id
    end

    it "should get the last insert id" do
      subject.last_id.should eq(@id)
    end

    it "should call all filters" do
      subject.all.size.should == 5
    end
  end

  context "no API responses" do
    it "should get nil as last insert id if no API responses" do
      subject.last_id.should be_nil
    end

    it "should get an empty result if no API responses" do
      subject.all.should be_empty
    end
  end

  context "decreasing event count" do
    context "real decrease" do
      let(:api_responses) { FactoryGirl.create_list(:api_response, 3, previous_count: 12) }
      let(:id) { api_responses.last.id }

      it "should raise errors" do
        subject.decreasing(id)[:result].should eq(api_responses.size)
        ErrorMessage.count.should == 3
        error_message = ErrorMessage.first
        error_message.class_name.should eq("EventCountDecreasingError")
        error_message.message.should eq("Event count decreased")
        error_message.source_id.should == 1
      end
    end

    context "decrease to zero" do
      let(:api_responses) { FactoryGirl.create_list(:api_response, 3, event_count: 0) }
      let(:id) { api_responses.last.id }

      it "should raise errors" do
        subject.decreasing(id)[:result].should eq(api_responses.size)
        ErrorMessage.count.should == 3
      end
    end

    context "success no data" do
      let(:api_responses) { FactoryGirl.create_list(:api_response, 3, event_count: 0) }
      let(:id) { api_responses.last.id }

      it "should raise errors" do
        subject.decreasing(id)[:result].should eq(api_responses.size)
        ErrorMessage.count.should == 3
      end
    end

    context "skipped" do
      let(:api_responses) { FactoryGirl.create_list(:api_response, 3, event_count: 0, retrieval_history_id: nil) }
      let(:id) { api_responses.last.id }

      it "should not raise errors" do
        subject.decreasing(id)[:result].should == 0
        ErrorMessage.count.should == 0
      end
    end

    context "API errors" do
      let(:api_responses) { FactoryGirl.create_list(:api_response, 3, event_count: nil) }
      let(:id) { api_responses.last.id }

      it "should not raise errors" do
        subject.decreasing(id)[:result].should == 0
        ErrorMessage.count.should == 0
      end
    end
  end

  context "increasing event count" do
    let(:api_responses) { FactoryGirl.create_list(:api_response, 3, event_count: 1050) }
    let(:id) { api_responses.last.id }

    it "should raise errors" do
      subject.increasing(id)[:result].should eq(api_responses.size)
      ErrorMessage.count.should == 3
      error_message = ErrorMessage.first
      error_message.class_name.should eq("EventCountIncreasingTooFastError")
      error_message.message.should eq("Event count increased too fast")
      error_message.source_id.should == 1
    end
  end

  context "slow API responses" do
    let(:api_responses) { FactoryGirl.create_list(:api_response, 3, duration: 16000) }
    let(:id) { api_responses.last.id }

    it "should raise errors" do
      subject.slow(id)[:result].should eq(api_responses.size)
      ErrorMessage.count.should == 3
      error_message = ErrorMessage.first
      error_message.class_name.should eq("ApiResponseTooSlowError")
      error_message.message.should eq("API response too slow")
      error_message.source_id.should == 1
    end
  end

  context "not_updated" do
    let(:api_responses) { FactoryGirl.create_list(:api_response, 3, update_interval: 42) }
    let(:id) { api_responses.last.id }

    it "should raise errors" do
      subject.not_updated(id)[:result].should eq(api_responses.size)
              ErrorMessage.count.should == 3
        error_message = ErrorMessage.first
        error_message.class_name.should eq("ArticleNotUpdatedError")
        error_message.message.should eq("Article not updated for too long")
        error_message.source_id.should == 1
    end
  end

  context "resolve" do
    let(:api_responses) { FactoryGirl.create_list(:api_response, 3) }
    let(:id) { api_responses.last.id }

    it "should resolve API responses" do
      subject.resolve(id)[:result].should eq(api_responses.size)
    end
  end
end
