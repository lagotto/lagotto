# encoding: UTF-8

require 'spec_helper'

describe Filter do

  context "class methods" do
    subject { Filter }

    it { should respond_to(:all) }
    it { should respond_to(:formatted_message) }
    it { should respond_to(:create_review) }
    it { should respond_to(:resolve) }
    it { should respond_to(:unresolve) }

    context "API responses" do
      before do
        @api_responses = FactoryGirl.create_list(:api_response, 3, event_count: 1050, duration: 16000)
        @id = @api_responses.last.id
      end

      it "should call all filters" do
        response = subject.all
        response[:id].should eq(@id)
        response[:output].should == 3
        response[:message].should include("Resolved 3 API responses")
        response[:review_messages].should eq(2)
      end
    end

    context "no API responses" do
      it "should get nil from all method" do
        subject.all.should be_nil
      end
    end

    context "no unresolved API responses" do
      before do
        @api_responses = FactoryGirl.create_list(:api_response, 3, unresolved: false)
      end

       it "should get nil from all method" do
        subject.all.should be_nil
      end
    end

    context "resolve" do
      let(:api_responses) { FactoryGirl.create_list(:api_response, 3) }
      let(:options) {{ id: api_responses.last.id }}

      it "should resolve API responses" do
        subject.resolve(options)[:output].should == api_responses.size
      end
    end

    context "unresolve" do
      before do
        @api_responses = FactoryGirl.create_list(:api_response, 3, unresolved: false)
      end

      it "should unresolve API responses" do
        subject.unresolve[:output].should == @api_responses.size
      end
    end
  end

  context "instance methods" do
    subject { FactoryGirl.create(:filter) }

    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:display_name) }
    it { should respond_to(:raise_errors) }
  end

  context "decreasing event count" do
    subject { FactoryGirl.create(:decreasing_event_count_error) }

    context "real decrease" do
      let(:api_responses) { FactoryGirl.create_list(:api_response, 3, previous_count: 12) }
      let(:options) {{ id: api_responses.last.id }}

      it "should raise errors" do
        subject.run_filter(options).should == api_responses.size
        ErrorMessage.count.should == 3
        error_message = ErrorMessage.first
        error_message.class_name.should eq("EventCountDecreasingError")
        error_message.message.should include("Event count decreased")
        error_message.source_id.should == 1
      end
    end

    context "decrease to zero" do
      let(:api_responses) { FactoryGirl.create_list(:api_response, 3, event_count: 0) }
      let(:options) {{ id: api_responses.last.id }}

      it "should raise errors" do
        subject.run_filter(options).should == api_responses.size
        ErrorMessage.count.should == 3
      end
    end

    context "success no data" do
      let(:api_responses) { FactoryGirl.create_list(:api_response, 3, event_count: 0) }
      let(:options) {{ id: api_responses.last.id }}

      it "should raise errors" do
        subject.run_filter(options).should == api_responses.size
        ErrorMessage.count.should == 3
      end
    end

    context "skipped" do
      let(:api_responses) { FactoryGirl.create_list(:api_response, 3, event_count: 0, retrieval_history_id: nil) }
      let(:options) {{ id: api_responses.last.id }}

      it "should not raise errors" do
        subject.run_filter(options).should == 0
        ErrorMessage.count.should == 0
      end
    end

    context "API errors" do
      let(:api_responses) { FactoryGirl.create_list(:api_response, 3, event_count: nil) }
      let(:options) {{ id: api_responses.last.id }}

      it "should not raise errors" do
        subject.run_filter(options).should == 0
        ErrorMessage.count.should == 0
      end
    end
  end

  context "increasing event count" do
    subject { FactoryGirl.create(:increasing_event_count_error) }

    context "real increase" do
      let(:api_responses) { FactoryGirl.create_list(:api_response, 3, event_count: 3600) }
      let(:options) {{ id: api_responses.last.id }}

      it "should raise errors" do
        subject.run_filter(options).should == api_responses.size
        ErrorMessage.count.should == 3
        error_message = ErrorMessage.first
        error_message.class_name.should eq("EventCountIncreasingTooFastError")
        error_message.message.should include("Event count increased")
        error_message.source_id.should == 1
      end
    end

    context "same day" do
      let(:api_responses) { FactoryGirl.create_list(:api_response, 3, event_count: 3600, update_interval: 0) }
      let(:options) {{ id: api_responses.last.id }}

      it "should raise errors" do
        subject.run_filter(options).should == api_responses.size
        ErrorMessage.count.should == 3
        error_message = ErrorMessage.first
        error_message.class_name.should eq("EventCountIncreasingTooFastError")
        error_message.message.should include("Event count increased")
        error_message.source_id.should == 1
      end
    end

    context "first time" do
      let(:api_responses) { FactoryGirl.create_list(:api_response, 3, event_count: 3600, update_interval: nil) }
      let(:options) {{ id: api_responses.last.id }}

      it "should not raise errors" do
        subject.run_filter(options).should == 0
        ErrorMessage.count.should == 0
      end
    end
  end

  context "slow API responses" do
    subject { FactoryGirl.create(:api_too_slow_error) }

    let(:duration) { 16000.0 }
    let(:api_responses) { FactoryGirl.create_list(:api_response, 3, duration: duration) }
    let(:options) {{ id: api_responses.last.id }}

    it "should raise errors" do
      subject.run_filter(options).should == api_responses.size
      ErrorMessage.count.should == 3
      error_message = ErrorMessage.first
      error_message.class_name.should eq("ApiResponseTooSlowError")
      error_message.message.should include("API response took #{duration} ms")
      error_message.source_id.should == 1
    end
  end

  context "article not updated" do
    subject { FactoryGirl.create(:article_not_updated_error) }

    let(:days) { 42 }
    let(:api_responses) { FactoryGirl.create_list(:api_response, 3, event_count: nil, update_interval: days) }
    let(:options) {{ id: api_responses.last.id }}

    it "should raise errors" do
      subject.run_filter(options).should == api_responses.size
      ErrorMessage.count.should == 3
      error_message = ErrorMessage.first
      error_message.class_name.should eq("ArticleNotUpdatedError")
      error_message.message.should include("Article not updated for #{days}")
      error_message.source_id.should == 1
    end
  end

  context "source not updated" do
    subject { FactoryGirl.create(:source_not_updated_error) }

    before do
      @citeulike = FactoryGirl.create(:citeulike)
      @mendeley = FactoryGirl.create(:mendeley)
    end

    let(:api_responses) { FactoryGirl.create_list(:api_response, 3, source_id: @citeulike.id) }
    let(:options) {{ id: api_responses.last.id }}

    it "should raise errors" do
      subject.run_filter(options).should == 1
      ErrorMessage.count.should == 1
      error_message = ErrorMessage.first
      error_message.class_name.should eq("SourceNotUpdatedError")
      error_message.message.should include("Source not updated for 24 hours")
      error_message.source_id.should == @mendeley.id
    end
  end
end
