require 'spec_helper'

describe RetrievalStatus do

  it { should belong_to(:article) }
  it { should belong_to(:source) }
  it { should have_many(:retrieval_histories).dependent(:destroy) }

  it "stale_at should be publication date for unpublished articles" do
    unpublished_article = build(:retrieval_status, :unpublished)
    unpublished_article.stale_at.to_date.should eq(unpublished_article.article.published_on)
  end

  context "use stale_at" do
    let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }

    it "stale_at should be a datetime" do
      retrieval_status.stale_at.should be_a_kind_of Time
    end

    it "stale_at should be in the future" do
      (retrieval_status.stale_at - Time.zone.now).should be > 0
    end

    it "stale_at should be after article publication date for published articles" do
      (retrieval_status.stale_at - retrieval_status.article.published_on.to_datetime).should be > 0
    end
  end

  context "staleness intervals" do

    it "published a day ago" do
      article = FactoryGirl.create(:article, :published_on => Time.zone.today - 1.day)
      retrieval_status = FactoryGirl.create(:retrieval_status, :article => article)
      duration = retrieval_status.source.staleness[0]
      (retrieval_status.stale_at - Time.zone.now).should be_within(0.11 * duration).of(duration)
    end

    it "published 8 days ago" do
      article = FactoryGirl.create(:article, :published_on => Time.zone.today - 8.days)
      retrieval_status = FactoryGirl.create(:retrieval_status, :article => article)
      duration = retrieval_status.source.staleness[1]
      (retrieval_status.stale_at - Time.zone.now).should be_within(0.11 * duration).of(duration)
    end

    it "published 32 days ago" do
      article = FactoryGirl.create(:article, :published_on => Time.zone.today - 32.days)
      retrieval_status = FactoryGirl.create(:retrieval_status, :article => article)
      duration = retrieval_status.source.staleness[2]
      (retrieval_status.stale_at - Time.zone.now).should be_within(0.11 * duration).of(duration)
    end

    it "published 370 days ago" do
      article = FactoryGirl.create(:article, :published_on => Time.zone.today - 370.days)
      retrieval_status = FactoryGirl.create(:retrieval_status, :article => article)
      duration = retrieval_status.source.staleness[3]
      (retrieval_status.stale_at - Time.zone.now).should be_within(0.11 * duration).of(duration)
    end
  end

  context "CouchDB" do
    let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }
    let(:citeulike) { FactoryGirl.create(:citeulike) }
    let(:rs_id) { "#{retrieval_status.source.name}:#{retrieval_status.article.doi_escaped}" }
    let(:error) {{ "error" => "not_found", "reason" => "deleted" }}

    subject { SourceJob.new([retrieval_status.id], citeulike.id) }

    before(:each) do
      subject.put_alm_database
    end

    after(:each) do
      subject.delete_alm_database
    end

    it "should perform and get data" do
      stub = stub_request(:get, citeulike.get_query_url(retrieval_status.article)).to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
      result = subject.perform_get_data(retrieval_status)
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

      retrieval_status.article.destroy
      subject.get_alm_data(rs_id).strip.should eq(error.to_json)
      subject.get_alm_data(rh_id).strip.should eq(error.to_json)
    end
  end
end
