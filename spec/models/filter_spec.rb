require 'rails_helper'

describe Filter, :type => :model do

  context "class methods" do
    subject { Filter }

    it { is_expected.to respond_to(:all) }
    it { is_expected.to respond_to(:formatted_message) }
    it { is_expected.to respond_to(:create_review) }
    it { is_expected.to respond_to(:resolve) }
    it { is_expected.to respond_to(:unresolve) }

    context "API responses" do
      before do
        @api_response = FactoryGirl.create(:api_response, previous_total: 12)
        @filter = FactoryGirl.create(:decreasing_event_count_error)
      end

      let(:id) { @api_response.id }

      it "should call all active filters" do
        response = subject.run
        expect(response[:id]).to eq(id)
        expect(response[:output]).to eq(1)
        expect(response[:message]).to include("Resolved 1 API response")
        expect(response[:review_messages].size).to eq(Filter.active.count)
        expect(response[:review_messages].first).to include("Found 1 decreasing event count error in 1 API response")
      end
    end

    context "no API responses" do
      it "should get nil from all method" do
        expect(subject.run).to be_nil
      end
    end

    context "no unresolved API responses" do
      before do
        @api_response = FactoryGirl.create(:api_response, unresolved: false)
      end

      it "should get nil from run method" do
        expect(subject.run).to be_nil
      end
    end

    context "resolve" do
      let(:api_response) { FactoryGirl.create(:api_response) }
      let(:options) { { id: api_response.id } }

      it "should resolve API responses" do
        expect(subject.resolve(options)[:output]).to eq(1)
      end
    end

    context "unresolve" do
      before do
        @api_response = FactoryGirl.create(:api_response, unresolved: false)
      end

      it "should unresolve API responses" do
        expect(subject.unresolve[:output]).to eq(1)
      end
    end
  end

  context "instance methods" do
    subject { FactoryGirl.create(:filter) }

    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to respond_to(:raise_alerts) }
  end

  context "decreasing event count" do
    subject { FactoryGirl.create(:decreasing_event_count_error) }

    context "real decrease" do
      let(:api_response) { FactoryGirl.create(:api_response, previous_total: 12) }
      let(:options) { { id: api_response.id } }

      it "should raise errors" do
        expect(subject.run_filter(options)).to eq(1)
        expect(Alert.count).to eq(1)
        alert = Alert.first
        expect(alert.class_name).to eq("EventCountDecreasingError")
        expect(alert.message).to include("Event count decreased")
        expect(alert.level).to eq(1)
        expect(alert.source_id).to eq(1)
      end
    end

    context "decrease to zero" do
      let(:api_response) { FactoryGirl.create(:api_response, total: 0) }
      let(:options) { { id: api_response.id } }

      it "should raise errors" do
        expect(subject.run_filter(options)).to eq(1)
        expect(Alert.count).to eq(1)
      end
    end

    context "success no data" do
      let(:api_response) { FactoryGirl.create(:api_response, total: 0) }
      let(:options) { { id: api_response.id } }

      it "should raise errors" do
        expect(subject.run_filter(options)).to eq(1)
        expect(Alert.count).to eq(1)
      end
    end

    context "skipped because of errors" do
      let(:api_response) { FactoryGirl.create(:api_response, total: 0, skipped: true) }
      let(:options) { { id: api_response.id } }

      it "should not raise errors" do
        expect(subject.run_filter(options)).to eq(0)
        expect(Alert.count).to eq(0)
      end
    end
  end

  context "increasing event count" do
    subject { FactoryGirl.create(:increasing_event_count_error) }

    context "real increase" do
      let(:api_response) { FactoryGirl.create(:api_response, total: 3600) }
      let(:options) { { id: api_response.id } }

      it "should raise errors" do
        expect(subject.run_filter(options)).to eq(1)
        expect(Alert.count).to eq(1)
        alert = Alert.first
        expect(alert.class_name).to eq("EventCountIncreasingTooFastError")
        expect(alert.message).to include("Event count increased")
        expect(alert.level).to eq(1)
        expect(alert.source_id).to eq(1)
      end
    end

    context "same day" do
      let(:api_response) { FactoryGirl.create(:api_response, total: 3600, update_interval: 1) }
      let(:options) { { id: api_response.id } }

      it "should raise errors" do
        expect(subject.run_filter(options)).to eq(1)
        expect(Alert.count).to eq(1)
        alert = Alert.first
        expect(alert.class_name).to eq("EventCountIncreasingTooFastError")
        expect(alert.message).to include("Event count increased")
        expect(alert.source_id).to eq(1)
      end
    end
  end

  context "HTML/PDF ratio" do
    subject { FactoryGirl.create(:html_ratio_too_high_error) }

    context "ratio too high" do
      let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0008776") }
      let(:counter) { FactoryGirl.create(:counter) }
      let(:api_response) { FactoryGirl.create(:api_response) }
      let(:options) { { id: api_response.id } }

      it "should raise errors" do
        # body = File.read(fixture_path + 'counter_too_many_html.xml')
        # stub = stub_request(:get, counter.get_query_url(work)).to_return(:body => body, :status => 200)
        # response = counter.get_data(work)
        # subject.get_lagotto_data("_design/filter/_view/html_ratio").should eq(2)
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
    let(:options) { { id: api_response.id } }

    it "should raise errors" do
      expect(subject.run_filter(options)).to eq(1)
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("ApiResponseTooSlowError")
      expect(alert.message).to include("API response took #{duration} ms")
      expect(alert.level).to eq(2)
      expect(alert.source_id).to eq(1)
    end
  end

  context "work not updated" do
    subject { FactoryGirl.create(:work_not_updated_error) }

    let(:days) { 42 }
    let(:api_response) { FactoryGirl.create(:api_response, total: 0, skipped: true, update_interval: days) }
    let(:options) { { id: api_response.id } }

    it "should raise errors" do
      expect(subject.run_filter(options)).to eq(1)
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("WorkNotUpdatedError")
      expect(alert.message).to include("Work not updated for #{days}")
      expect(alert.level).to eq(3)
      expect(alert.source_id).to eq(1)
    end
  end

  context "source not updated" do
    subject { FactoryGirl.create(:source_not_updated_error) }

    before do
      @citeulike = FactoryGirl.create(:citeulike)
      @mendeley = FactoryGirl.create(:mendeley)
      @report = FactoryGirl.create(:stale_source_report_with_admin_user)
    end

    let(:api_response) { FactoryGirl.create(:api_response, source_id: @citeulike.id) }
    let(:options) { { id: api_response.id } }

    it "should raise errors" do
      expect(subject.run_filter(options)).to eq(1)
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("SourceNotUpdatedError")
      expect(alert.message).to include("Source not updated for 24 hours")
      expect(alert.level).to eq(3)
      expect(alert.source_id).to eq(@mendeley.id)
    end
  end
end
