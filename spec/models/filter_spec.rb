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
        @api_response = FactoryGirl.create(:api_response, previous_count: 12)
        @filter = FactoryGirl.create(:decreasing_event_count_error)
      end

      let(:id) { @api_response.id }

      it "should call all active filters" do
        response = subject.all
        response[:id].should eq(id)
        response[:output].should == 1
        response[:message].should include("Resolved 1 API response")
        response[:review_messages].size.should == Filter.active.count
        response[:review_messages].first.should include("Found 1 decreasing event count error in 1 API response")
      end
    end

    context "no API responses" do
      it "should get nil from all method" do
        subject.all.should be_nil
      end
    end

    context "no unresolved API responses" do
      before do
        @api_response = FactoryGirl.create(:api_response, unresolved: false)
      end

       it "should get nil from all method" do
        subject.all.should be_nil
      end
    end

    context "resolve" do
      let(:api_response) { FactoryGirl.create(:api_response) }
      let(:options) {{ id: api_response.id }}

      it "should resolve API responses" do
        subject.resolve(options)[:output].should == 1
      end
    end

    context "unresolve" do
      before do
        @api_response = FactoryGirl.create(:api_response, unresolved: false)
      end

      it "should unresolve API responses" do
        subject.unresolve[:output].should == 1
      end
    end
  end

  context "instance methods" do
    subject { FactoryGirl.create(:filter) }

    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:display_name) }
    it { should respond_to(:raise_alerts) }
  end

  context "decreasing event count" do
    subject { FactoryGirl.create(:decreasing_event_count_error) }

    context "real decrease" do
      let(:api_response) { FactoryGirl.create(:api_response, previous_count: 12) }
      let(:options) {{ id: api_response.id }}

      it "should raise errors" do
        subject.run_filter(options).should == 1
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("EventCountDecreasingError")
        alert.message.should include("Event count decreased")
        alert.source_id.should == 1
      end
    end

    context "decrease to zero" do
      let(:api_response) { FactoryGirl.create(:api_response, event_count: 0) }
      let(:options) {{ id: api_response.id }}

      it "should raise errors" do
        subject.run_filter(options).should == 1
        Alert.count.should == 1
      end
    end

    context "success no data" do
      let(:api_response) { FactoryGirl.create(:api_response, event_count: 0) }
      let(:options) {{ id: api_response.id }}

      it "should raise errors" do
        subject.run_filter(options).should == 1
        Alert.count.should == 1
      end
    end

    context "skipped" do
      let(:api_response) { FactoryGirl.create(:api_response, event_count: 0, retrieval_history_id: nil) }
      let(:options) {{ id: api_response.id }}

      it "should not raise errors" do
        subject.run_filter(options).should == 0
        Alert.count.should == 0
      end
    end

    context "API errors" do
      let(:api_response) { FactoryGirl.create(:api_response, event_count: nil) }
      let(:options) {{ id: api_response.id }}

      it "should not raise errors" do
        subject.run_filter(options).should == 0
        Alert.count.should == 0
      end
    end
  end

  context "increasing event count" do
    subject { FactoryGirl.create(:increasing_event_count_error) }

    context "real increase" do
      let(:api_response) { FactoryGirl.create(:api_response, event_count: 3600) }
      let(:options) {{ id: api_response.id }}

      it "should raise errors" do
        subject.run_filter(options).should == 1
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("EventCountIncreasingTooFastError")
        alert.message.should include("Event count increased")
        alert.source_id.should == 1
      end
    end

    context "same day" do
      let(:api_response) { FactoryGirl.create(:api_response, event_count: 3600, update_interval: 1) }
      let(:options) {{ id: api_response.id }}

      it "should raise errors" do
        subject.run_filter(options).should == 1
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("EventCountIncreasingTooFastError")
        alert.message.should include("Event count increased")
        alert.source_id.should == 1
      end
    end
  end

  context "HTML/PDF ratio" do
    subject { FactoryGirl.create(:html_ratio_too_high_error) }

    before(:each) do
      #subject.put_alm_database
    end

    after(:each) do
      subject.delete_alm_database
    end

    context "ratio too high" do
      let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776") }
      let(:counter) { FactoryGirl.create(:counter) }
      let(:api_response) { FactoryGirl.create(:api_response) }
      let(:options) {{ id: api_response.id }}

      it "should raise errors" do
        # body = File.read(fixture_path + 'counter_too_many_html.xml')
        # stub = stub_request(:get, counter.get_query_url(article)).to_return(:body => body, :status => 200)
        # response = counter.get_data(article)
        # subject.get_alm_data("_design/filter/_view/html_ratio").should eq(2)
        # subject.run_filter(options).should == 1
        # Alert.count.should == 1
        # alert = Alert.first
        # alert.class_name.should eq("HtmlRatioTooHighError")
        # alert.message.should include("Event count increased")
        # alert.source_id.should == 1
      end
    end
  end

  context "slow API responses" do
    subject { FactoryGirl.create(:api_too_slow_error) }

    let(:duration) { 31000.0 }
    let(:api_response) { FactoryGirl.create(:api_response, duration: duration) }
    let(:options) {{ id: api_response.id }}

    it "should raise errors" do
      subject.run_filter(options).should == 1
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("ApiResponseTooSlowError")
      alert.message.should include("API response took #{duration} ms")
      alert.source_id.should == 1
    end
  end

  context "article not updated" do
    subject { FactoryGirl.create(:article_not_updated_error) }

    let(:days) { 42 }
    let(:api_response) { FactoryGirl.create(:api_response, event_count: nil, update_interval: days) }
    let(:options) {{ id: api_response.id }}

    it "should raise errors" do
      subject.run_filter(options).should == 1
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("ArticleNotUpdatedError")
      alert.message.should include("Article not updated for #{days}")
      alert.source_id.should == 1
    end
  end

  context "source not updated" do
    subject { FactoryGirl.create(:source_not_updated_error) }

    before do
      @citeulike = FactoryGirl.create(:citeulike)
      @mendeley = FactoryGirl.create(:mendeley)
    end

    let(:api_response) { FactoryGirl.create(:api_response, source_id: @citeulike.id) }
    let(:options) {{ id: api_response.id }}

    it "should raise errors" do
      subject.run_filter(options).should == 1
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("SourceNotUpdatedError")
      alert.message.should include("Source not updated for 24 hours")
      alert.source_id.should == @mendeley.id
    end
  end
end
