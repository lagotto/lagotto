require 'rails_helper'

describe RetrievalStatus, :type => :model do
  before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  it { is_expected.to belong_to(:work) }
  it { is_expected.to belong_to(:source) }

  describe "use stale_at" do
    let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }

    it "stale_at should be a datetime" do
      expect(retrieval_status.stale_at).to be_a_kind_of Time
    end

    it "stale_at should be in the future" do
      expect(retrieval_status.stale_at - Time.zone.now).to be > 0
    end

    it "stale_at should be after work publication date" do
      expect(retrieval_status.stale_at - retrieval_status.work.published_on.to_datetime).to be > 0
    end
  end

  describe "staleness intervals" do
    it "published a day ago" do
      date = Time.zone.now - 1.day
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      retrieval_status = FactoryGirl.create(:retrieval_status, :work => work)
      duration = retrieval_status.source.staleness[0]
      expect(retrieval_status.stale_at - Time.zone.now).to be_within(0.11 * duration).of(duration)
    end

    it "published 8 days ago" do
      date = Time.zone.now - 8.days
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      retrieval_status = FactoryGirl.create(:retrieval_status, :work => work)
      duration = retrieval_status.source.staleness[1]
      expect(retrieval_status.stale_at - Time.zone.now).to be_within(0.11 * duration).of(duration)
    end

    it "published 32 days ago" do
      date = Time.zone.now - 32.days
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      retrieval_status = FactoryGirl.create(:retrieval_status, :work => work)
      duration = retrieval_status.source.staleness[2]
      expect(retrieval_status.stale_at - Time.zone.now).to be_within(0.11 * duration).of(duration)
    end

    it "published 370 days ago" do
      date = Time.zone.now - 370.days
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      retrieval_status = FactoryGirl.create(:retrieval_status, :work => work)
      duration = retrieval_status.source.staleness[3]
      expect(retrieval_status.stale_at - Time.zone.now).to be_within(0.15 * duration).of(duration)
    end
  end

  describe "CouchDB" do
    let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }
    let(:rs_id) { "#{retrieval_status.source.name}:#{retrieval_status.work.doi_escaped}" }
    let(:error) { { "error" => "not_found", "reason" => "deleted" } }

    before(:each) do
      subject.put_lagotto_database
    end

    after(:each) do
      subject.delete_lagotto_database
    end

    it "should perform and get data" do
      stub = stub_request(:get, retrieval_status.source.get_query_url(retrieval_status.work))
             .to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
      result = retrieval_status.perform_get_data

      rs_result = retrieval_status.get_lagotto_data(rs_id)
      # rs_result.should include("source" => retrieval_status.source.name,
      #                          "doi" => retrieval_status.work.doi,
      #                          "doc_type" => "current",
      #                          "_id" =>  "#{retrieval_status.source.name}:#{retrieval_status.work.doi}")
      # rh_result = retrieval_status.get_lagotto_data(rh_id)
      # rh_result.should include("source" => retrieval_status.source.name,
      #                          "doi" => retrieval_status.work.doi,
      #                          "doc_type" => "history",
      #                          "_id" => "#{rh_id}")

      # retrieval_status.work.destroy
      # subject.get_lagotto_data(rs_id).should eq(error)
      # subject.get_lagotto_data(rh_id).should eq(error)
    end
  end

  describe "retrieval_histories" do
    let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :with_crossref_histories) }

    it "should get past events by month" do
      expect(retrieval_status.get_past_events_by_month).to eq([{:year=>2013, :month=>4, :total=>790}, {:year=>2013, :month=>5, :total=>820}, {:year=>2013, :month=>6, :total=>870}, {:year=>2013, :month=>7, :total=>910}, {:year=>2013, :month=>8, :total=>950}])
    end
  end
end
