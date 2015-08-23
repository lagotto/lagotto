require 'rails_helper'

describe Deposit, :type => :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:deposit) }

  it { is_expected.to validate_presence_of(:uuid) }
  it { is_expected.to validate_uniqueness_of(:uuid) }
  it { is_expected.to validate_presence_of(:message_type) }
  it { is_expected.to validate_presence_of(:message) }

  describe "update_works" do
    let!(:relation_type) { FactoryGirl.create(:relation_type) }
    let!(:inverse_relation_type) { FactoryGirl.create(:relation_type, :inverse) }

    it "crossref" do
      related_work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0043007")
      works = [{"author"=>[{"family"=>"Occelli", "given"=>"Valeria"}, {"family"=>"Spence", "given"=>"Charles"}, {"family"=>"Zampini", "given"=>"Massimiliano"}], "title"=>"Audiotactile Interactions In Temporal Perception", "container-title"=>"Psychonomic Bulletin & Review", "issued"=>{"date-parts"=>[[2011]]}, "DOI"=>"10.3758/s13423-011-0070-4", "volume"=>"18", "issue"=>"3", "page"=>"429", "type"=>"article-journal", "related_works"=>[{"related_work"=>"doi:10.1371/journal.pone.0043007", "source"=>"crossref", "relation_type"=>"cites"}]}]
      subject = FactoryGirl.create(:deposit, message_type: "crossref", message: { "works" => works })
      expect(subject.update_works).to eq(["http://doi.org/10.3758/s13423-011-0070-4"])

      expect(Work.count).to eq(2)
      work = Work.last
      expect(work.title).to eq("Audiotactile Interactions In Temporal Perception")
      expect(work.pid).to eq("http://doi.org/10.3758/s13423-011-0070-4")

      expect(work.relations.length).to eq(1)
      relation = Relation.first
      expect(relation.relation_type.name).to eq("cites")
      expect(relation.source.name).to eq("crossref")
      expect(relation.related_work).to eq(related_work)
    end
  end

  context "update_events" do
    let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0115074", year: 2014, month: 12, day: 16) }
    let(:source) { FactoryGirl.create(:source) }

    it "success" do
      events = [{ "source_id" => source.name, "work_id" => work.pid, "total"=> 12, "readers" => 12 }]
      subject = FactoryGirl.create(:deposit, message: { "events" => events })

      event = subject.update_events.first
      expect(event.total).to eq(12)
      expect(event.readers).to eq(12)
      expect(event.months.count).to eq(1)

      month = event.months.last
      expect(month.year).to eq(2015)
      expect(month.month).to eq(4)
      expect(month.total).to eq(12)
      expect(month.readers).to eq(12)

      expect(event.days.count).to eq(0)
    end

    it "success counter" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0116034")
      source = FactoryGirl.create(:source, :counter)
      events = [{ "source_id" => source.name, "work_id" => work.pid, "total"=> 157, "pdf" => 24, "html" => 122 }]
      subject = FactoryGirl.create(:deposit, message: { "events" => events })

      event = subject.update_events.first
      expect(event.total).to eq(157)
      expect(event.pdf).to eq(24)
      expect(event.html).to eq(122)
      expect(event.months.count).to eq(1)
      expect(event.days.count).to eq(0)

      month = event.months.last
      expect(month.year).to eq(2015)
      expect(month.month).to eq(4)
      expect(month.total).to eq(157)
      expect(month.pdf).to eq(24)
      expect(month.html).to eq(122)
    end
  end

  describe "update_months" do
    let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0115074", year: 2014, month: 12, day: 16) }
    let(:agent) { FactoryGirl.create(:agent) }
    subject { FactoryGirl.create(:deposit) }

    it "citeulike" do
      body = File.read(fixture_path + 'citeulike.xml')
      #stub = stub_request(:get, agent.get_query_url(work)).to_return(:body => body)

      response = agent.collect_data(work.id)

      notification = Notification.first
      expect(notification).to eq(2)
      subject = Deposit.where(uuid: response.fetch("uuid")).first
      subject.update_events

      expect(Month.count).to eq(2)

      month = Month.last
      expect(month.year).to eq(2015)
      expect(month.month).to eq(1)
      expect(month.total).to eq(2)
      expect(month.readers).to eq(2)
    end

    it "mendeley" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776")
      agent = FactoryGirl.create(:mendeley)
      body = File.read(fixture_path + 'mendeley.json')
      stub = stub_request(:get, agent.get_query_url(work)).to_return(:body => body)

      response = agent.collect_data(work.id)
      subject = Deposit.where(uuid: response.fetch("uuid")).first
      subject.update_events

      expect(Month.count).to eq(1)

      month = Month.last
      expect(month.year).to eq(2015)
      expect(month.month).to eq(4)
      expect(month.total).to eq(34)
      expect(month.readers).to eq(34)
    end
  end
end
