require 'spec_helper'

describe RetrievalStatus do
  before(:each) { Date.stub(:today).and_return(Date.new(2013, 9, 5)) }

  it { should belong_to(:article) }
  it { should belong_to(:source) }

  describe "use stale_at" do
    let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }

    it "stale_at should be a datetime" do
      retrieval_status.stale_at.should be_a_kind_of Time
    end

    it "stale_at should be in the future" do
      (retrieval_status.stale_at - Time.zone.now).should be > 0
    end

    it "stale_at should be after article publication date" do
      (retrieval_status.stale_at - retrieval_status.article.published_on.to_datetime).should be > 0
    end
  end

  describe "staleness intervals" do
    it "published a day ago" do
      date = Time.zone.today - 1.day
      article = FactoryGirl.create(:article, year: date.year, month: date.month, day: date.day)
      retrieval_status = FactoryGirl.create(:retrieval_status, :article => article)
      duration = retrieval_status.source.staleness[0]
      (retrieval_status.stale_at - Time.zone.now).should be_within(0.11 * duration).of(duration)
    end

    it "published 8 days ago" do
      date = Time.zone.today - 8.days
      article = FactoryGirl.create(:article, year: date.year, month: date.month, day: date.day)
      retrieval_status = FactoryGirl.create(:retrieval_status, :article => article)
      duration = retrieval_status.source.staleness[1]
      (retrieval_status.stale_at - Time.zone.now).should be_within(0.11 * duration).of(duration)
    end

    it "published 32 days ago" do
      date = Time.zone.today - 32.days
      article = FactoryGirl.create(:article, year: date.year, month: date.month, day: date.day)
      retrieval_status = FactoryGirl.create(:retrieval_status, :article => article)
      duration = retrieval_status.source.staleness[2]
      (retrieval_status.stale_at - Time.zone.now).should be_within(0.11 * duration).of(duration)
    end

    it "published 370 days ago" do
      date = Time.zone.today - 370.days
      article = FactoryGirl.create(:article, year: date.year, month: date.month, day: date.day)
      retrieval_status = FactoryGirl.create(:retrieval_status, :article => article)
      duration = retrieval_status.source.staleness[3]
      (retrieval_status.stale_at - Time.zone.now).should be_within(0.11 * duration).of(duration)
    end
  end

  describe "CouchDB" do
    let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }
    let(:rs_id) { "#{retrieval_status.source.name}:#{retrieval_status.article.doi_escaped}" }
    let(:error) { { "error" => "not_found", "reason" => "deleted" } }

    before(:each) do
      subject.put_alm_database
    end

    after(:each) do
      subject.delete_alm_database
    end

    it "should perform and get data" do
      stub = stub_request(:get, retrieval_status.source.get_query_url(retrieval_status.article))
        .to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
      result = retrieval_status.perform_get_data

      rs_result = retrieval_status.get_alm_data(rs_id)
      # rs_result.should include("source" => retrieval_status.source.name,
      #                          "doi" => retrieval_status.article.doi,
      #                          "doc_type" => "current",
      #                          "_id" =>  "#{retrieval_status.source.name}:#{retrieval_status.article.doi}")
      # rh_result = retrieval_status.get_alm_data(rh_id)
      # rh_result.should include("source" => retrieval_status.source.name,
      #                          "doi" => retrieval_status.article.doi,
      #                          "doc_type" => "history",
      #                          "_id" => "#{rh_id}")

      # retrieval_status.article.destroy
      # subject.get_alm_data(rs_id).should eq(error)
      # subject.get_alm_data(rh_id).should eq(error)
    end
  end

  describe "retrieval_histories" do
    let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :with_crossref_histories) }

    it "should get past events by month" do
      retrieval_status.get_past_events_by_month.should eq([{:year=>2013, :month=>4, :total=>810}, {:year=>2013, :month=>5, :total=>860}, {:year=>2013, :month=>6, :total=>900}, {:year=>2013, :month=>7, :total=>940}, {:year=>2013, :month=>8, :total=>990}])
    end
  end
end
