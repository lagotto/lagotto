require 'rails_helper'

describe Task, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  it { is_expected.to belong_to(:work) }
  it { is_expected.to belong_to(:agent) }

  describe "use stale_at" do
    subject { FactoryGirl.create(:task) }

    it "stale_at should be a datetime" do
      expect(subject.stale_at).to be_a_kind_of Time
    end

    it "stale_at should be in the future" do
      expect(subject.stale_at - Time.zone.now).to be > 0
    end

    it "stale_at should be after work publication date" do
      expect(subject.stale_at - subject.work.published_on.to_datetime).to be > 0
    end
  end

  describe "staleness intervals" do
    it "published a day ago" do
      date = Time.zone.now - 1.day
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      subject = FactoryGirl.create(:task, :work => work)
      duration = subject.agent.staleness[0]
      expect(subject.stale_at - Time.zone.now).to be_within(0.11 * duration).of(duration)
    end

    it "published 8 days ago" do
      date = Time.zone.now - 8.days
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      subject = FactoryGirl.create(:task, :work => work)
      duration = subject.agent.staleness[1]
      expect(subject.stale_at - Time.zone.now).to be_within(0.11 * duration).of(duration)
    end

    it "published 32 days ago" do
      date = Time.zone.now - 32.days
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      subject = FactoryGirl.create(:task, :work => work)
      duration = subject.agent.staleness[2]
      expect(subject.stale_at - Time.zone.now).to be_within(0.11 * duration).of(duration)
    end

    it "published 370 days ago" do
      date = Time.zone.now - 370.days
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      subject = FactoryGirl.create(:task, :work => work)
      duration = subject.agent.staleness[3]
      expect(subject.stale_at - Time.zone.now).to be_within(0.15 * duration).of(duration)
    end
  end

  describe "retrieved_days_ago" do
    it "today" do
      subject = FactoryGirl.create(:task, retrieved_at: Time.zone.now)
      expect(subject.retrieved_days_ago).to eq(1)
    end

    it "two days" do
      subject = FactoryGirl.create(:task, retrieved_at: Time.zone.now - 2.days)
      expect(subject.retrieved_days_ago).to eq(2)
    end

    it "never" do
      subject = FactoryGirl.create(:task, retrieved_at: Date.new(1970, 1, 1))
      expect(subject.retrieved_days_ago).to eq(1)
    end
  end

  context "perform_get_data" do
    let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0115074", year: 2014, month: 12, day: 16) }
    subject { FactoryGirl.create(:task, work: work) }

    it "success" do
      deposit = subject.perform_get_data
      expect(deposit["message_type"]).to eq("citeulike")
      expect(deposit["message"]["works"].length).to eq(4)

      event = deposit["message"]["events"].first
      expect(event["source_id"]).to eq("citeulike")
      expect(event["work_id"]).to eq(work.pid)

      expect(Deposit.count).to eq(1)
    end

    it "success counter" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0116034")
      agent = FactoryGirl.create(:counter)
      subject = FactoryGirl.create(:task, work: work, agent: agent)

      deposit = subject.perform_get_data
      expect(deposit["message_type"]).to eq("counter")
      expect(deposit["message"]["works"]).to be_nil

      event = deposit["message"]["events"].first
      expect(event["source_id"]).to eq("counter")
      expect(event["work_id"]).to eq(work.pid)

      expect(Deposit.count).to eq(1)
    end

    it "success mendeley" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776")
      agent = FactoryGirl.create(:mendeley)
      subject = FactoryGirl.create(:task, work: work, agent: agent)
      body = File.read(fixture_path + 'mendeley.json')
      stub = stub_request(:get, subject.agent.get_query_url(work)).to_return(:body => body)

      deposit = subject.perform_get_data
      expect(deposit["message_type"]).to eq("mendeley")
      expect(deposit["message"]["works"]).to be_nil

      event = deposit["message"]["events"].first
      expect(event["source_id"]).to eq("mendeley")
      expect(event["work_id"]).to eq(work.pid)

      expect(Deposit.count).to eq(1)
    end

    it "success crossref" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0053745")
      agent = FactoryGirl.create(:crossref)
      subject = FactoryGirl.create(:task, work: work, agent: agent)
      body = File.read(fixture_path + 'cross_ref.xml')
      stub = stub_request(:get, subject.agent.get_query_url(work)).to_return(:body => body)

      deposit = subject.perform_get_data
      expect(deposit["message_type"]).to eq("crossref")
      expect(deposit["message"]["works"].length).to eq(31)

      event = deposit["message"]["events"].first
      expect(event["source_id"]).to eq("crossref")
      expect(event["work_id"]).to eq(work.pid)

      expect(Deposit.count).to eq(1)
    end

    it "success no data" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0116034")
      subject = FactoryGirl.create(:task, work: work)

      deposit = subject.perform_get_data
      expect(deposit).to be_empty

      expect(Deposit.count).to eq(0)
    end

    it "error" do
      stub = stub_request(:get, subject.agent.get_query_url(subject.work)).to_return(:status => [408])
      deposit = subject.perform_get_data
      expect(deposit).to be_empty

      expect(Deposit.count).to eq(0)
    end
  end
end
