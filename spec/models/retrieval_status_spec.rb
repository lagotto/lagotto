require 'rails_helper'

describe RetrievalStatus, type: :model, vcr: true, focus: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  it { is_expected.to belong_to(:work) }
  it { is_expected.to belong_to(:source) }
  it { is_expected.to have_many(:months) }
  it { is_expected.to have_many(:days) }

  describe "use stale_at" do
    subject { FactoryGirl.create(:retrieval_status) }

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
      subject = FactoryGirl.create(:retrieval_status, :work => work)
      duration = subject.source.staleness[0]
      expect(subject.stale_at - Time.zone.now).to be_within(0.11 * duration).of(duration)
    end

    it "published 8 days ago" do
      date = Time.zone.now - 8.days
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      subject = FactoryGirl.create(:retrieval_status, :work => work)
      duration = subject.source.staleness[1]
      expect(subject.stale_at - Time.zone.now).to be_within(0.11 * duration).of(duration)
    end

    it "published 32 days ago" do
      date = Time.zone.now - 32.days
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      subject = FactoryGirl.create(:retrieval_status, :work => work)
      duration = subject.source.staleness[2]
      expect(subject.stale_at - Time.zone.now).to be_within(0.11 * duration).of(duration)
    end

    it "published 370 days ago" do
      date = Time.zone.now - 370.days
      work = FactoryGirl.create(:work, year: date.year, month: date.month, day: date.day)
      subject = FactoryGirl.create(:retrieval_status, :work => work)
      duration = subject.source.staleness[3]
      expect(subject.stale_at - Time.zone.now).to be_within(0.15 * duration).of(duration)
    end
  end

  describe "retrieved_days_ago" do
    it "today" do
      subject = FactoryGirl.create(:retrieval_status, retrieved_at: Time.zone.now)
      expect(subject.retrieved_days_ago).to eq(1)
    end

    it "two days" do
      subject = FactoryGirl.create(:retrieval_status, retrieved_at: Time.zone.now - 2.days)
      expect(subject.retrieved_days_ago).to eq(2)
    end

    it "never" do
      subject = FactoryGirl.create(:retrieval_status, retrieved_at: Date.new(1970, 1, 1))
      expect(subject.retrieved_days_ago).to eq(1)
    end
  end

  describe "get_events_previous_day" do
    it "no days" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref)
      expect(subject.get_events_previous_day).to eq(pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 0)
    end

    it "current day" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref_current_day)
      expect(subject.get_events_previous_day).to eq(pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 0)
    end

    it "last day" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref_last_day)
      expect(subject.get_events_previous_day).to eq(pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 20)
    end
  end

  describe "get_events_current_day" do
    it "no days" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref)
      expect(subject.get_events_current_day).to eq(year: 2015, month: 4, day: 8, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 25)
    end

    it "current day" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref_current_day)
      expect(subject.get_events_current_day).to eq(year: 2015, month: 4, day: 8, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 20)
    end

    it "last day" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref_last_day)
      expect(subject.get_events_current_day).to eq(year: 2015, month: 4, day: 8, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 5)
    end
  end

  describe "get_events_previous_month" do
    it "no months" do
      subject = FactoryGirl.create(:retrieval_status)
      expect(subject.get_events_previous_month).to eq(pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 0)
    end

    it "current month" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref_current_month)
      expect(subject.get_events_previous_month).to eq(pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 0)
    end

    it "last month" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref_last_month)
      expect(subject.get_events_previous_month).to eq(pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 20)
    end
  end

  describe "get_events_current_month" do
    it "no days" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref)
      expect(subject.get_events_current_month).to eq(year: 2015, month: 4, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 25)
    end

    it "current month" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref_current_month)
      expect(subject.get_events_current_month).to eq(year: 2015, month: 4, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 20)
    end

    it "last month" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref_last_month)
      expect(subject.get_events_current_month).to eq(year: 2015, month: 4, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 5)
    end
  end

  describe "update_works" do
    subject { FactoryGirl.create(:retrieval_status, :with_crossref) }
    let!(:relation_type) { FactoryGirl.create(:relation_type) }
    let!(:inverse_relation_type) { FactoryGirl.create(:relation_type, :inverse) }

    it "no works" do
      data = []
      expect(subject.update_works(data)).to be_empty
    end

    #TODO fix broken test
    xit "work from CrossRef" do
      related_work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0043007")
      data = [{"author"=>[{"family"=>"Occelli", "given"=>"Valeria"}, {"family"=>"Spence", "given"=>"Charles"}, {"family"=>"Zampini", "given"=>"Massimiliano"}], "title"=>"Audiotactile Interactions In Temporal Perception", "container-title"=>"Psychonomic Bulletin & Review", "issued"=>{"date-parts"=>[[2011]]}, "DOI"=>"10.3758/s13423-011-0070-4", "volume"=>"18", "issue"=>"3", "page"=>"429", "type"=>"article-journal", "related_works"=>[{"related_work"=>"doi:10.1371/journal.pone.0043007", "source"=>"crossref", "relation_type"=>"cites"}]}]
      expect(subject.update_works(data)).to eq(["http://doi.org/10.3758/s13423-011-0070-4"])

      expect(Work.count).to eq(4)
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

  describe "update_months" do
    let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0115074", year: 2014, month: 12, day: 16) }
    subject { FactoryGirl.create(:retrieval_status, total: 2, readers: 2, work: work) }

    it "citeulike" do
      data = subject.source.get_data(work, work_id: subject.work_id, source_id: subject.source_id)
      data = subject.source.parse_data(data, subject.work, work_id: subject.work_id, source_id: subject.source_id)

      data[:months] = data.fetch(:events, {}).fetch(:months, [])
      subject.update_months(data.fetch(:months))
      expect(subject.months.count).to eq(3)

      month = subject.months.last
      expect(month.year).to eq(2015)
      expect(month.month).to eq(7)
      expect(month.total).to eq(2)
      expect(month.readers).to eq(2)
    end

    it "mendeley" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776")
      source = FactoryGirl.create(:mendeley)
      subject = FactoryGirl.create(:retrieval_status, total: 0, readers: 0, work: work, source: source)
      body = File.read(fixture_path + 'mendeley.json')
      stub = stub_request(:get, subject.source.get_query_url(work)).to_return(:body => body)

      data = subject.source.get_data(work, work_id: subject.work_id, source_id: subject.source_id)
      data = subject.source.parse_data(data, subject.work, work_id: subject.work_id, source_id: subject.source_id)

      subject.update_data(data.fetch(:events))

      data[:months] = [subject.get_events_current_month]
      subject.update_months(data.fetch(:months))
      expect(subject.months.count).to eq(1)

      month = subject.months.last
      expect(month.year).to eq(2015)
      expect(month.month).to eq(4)
      expect(month.total).to eq(34)
      expect(month.readers).to eq(34)
    end
  end

  context "perform_get_data" do
    let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0115074", year: 2014, month: 12, day: 16) }
    let!(:relation_type) { FactoryGirl.create(:relation_type, name: "bookmarks", title: "Bookmarks", inverse_name: "is_bookmarked_by") }
    let!(:inverse_relation_type) { FactoryGirl.create(:relation_type, name: "is_bookmarked_by", title: "Is bookmarked by", inverse_name: "bookmarks") }
    subject { FactoryGirl.create(:retrieval_status, total: 2, readers: 2, work: work) }

    it "success" do
      expect(subject.months.count).to eq(0)
      expect(subject.perform_get_data).to eq(total: 6, html: 0, pdf: 0, previous_total: 2, skipped: false, update_interval: 31)
      expect(subject.total).to eq(6)
      expect(subject.readers).to eq(6)
      expect(subject.months.count).to eq(3)
      expect(subject.days.count).to eq(2)

      month = subject.months.last
      expect(month.year).to eq(2015)
      expect(month.month).to eq(7)
      expect(month.total).to eq(2)
      expect(month.readers).to eq(2)

      day = subject.days.last
      expect(day.year).to eq(2014)
      expect(day.month).to eq(12)
      expect(day.day).to eq(30)
      expect(day.total).to eq(1)
      expect(day.readers).to eq(1)

      expect(Relation.count).to eq(8)
      relation = Relation.first
      expect(relation.relation_type.name).to eq("bookmarks")
      expect(relation.source.name).to eq("citeulike")
      expect(relation.work.pid).to eq("http://www.citeulike.org/user/shandar")
      expect(relation.related_work.pid).to eq(work.pid)
    end

    it "success counter" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0116034")
      source = FactoryGirl.create(:counter)
      subject = FactoryGirl.create(:retrieval_status, total: 50, pdf: 10, html: 40, work: work, source: source)

      expect(subject.months.count).to eq(0)
      expect(subject.perform_get_data).to eq(total: 187, html: 146, pdf: 30, previous_total: 50, skipped: false, update_interval: 31)
      expect(subject.total).to eq(187)
      expect(subject.pdf).to eq(30)
      expect(subject.html).to eq(146)
      expect(subject.months.count).to eq(8)
      expect(subject.days.count).to eq(0)
      expect(subject.extra.length).to eq(8)

      month = subject.months.last
      expect(month.year).to eq(2015)
      expect(month.month).to eq(7)
      expect(month.total).to eq(4)
      expect(month.pdf).to eq(1)
      expect(month.html).to eq(3)

      extra = subject.extra.last
      expect(extra).to eq("month"=>"7", "year"=>"2015", "pdf_views"=>"1", "xml_views"=>"0", "html_views"=>"3")
    end

    it "success mendeley" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776")
      source = FactoryGirl.create(:mendeley)
      subject = FactoryGirl.create(:retrieval_status, total: 0, readers: 0, work: work, source: source)
      body = File.read(fixture_path + 'mendeley.json')
      stub = stub_request(:get, subject.source.get_query_url(work)).to_return(:body => body)

      expect(subject.months.count).to eq(0)
      expect(subject.perform_get_data).to eq(total: 34, html: 0, pdf: 0, previous_total: 0, skipped: false, update_interval: 31)
      expect(subject.total).to eq(34)
      expect(subject.months.count).to eq(1)
      expect(subject.days.count).to eq(0)
      expect(Relation.count).to eq(0)

      month = subject.months.last
      expect(month.year).to eq(2015)
      expect(month.month).to eq(4)
      expect(month.total).to eq(34)
    end

    context "success with crossref data source" do
      before do
        work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0053745")
        relation_type = FactoryGirl.create(:relation_type)
        inverse_relation_type = FactoryGirl.create(:relation_type, :inverse)
        source = FactoryGirl.create(:crossref)
        @subject = FactoryGirl.create(:retrieval_status, total: 0, readers: 0, work: work, source: source)
        body = File.read(fixture_path + 'cross_ref.xml')
        stub_request(:get, @subject.source.get_query_url(work)).to_return(:body => body)
      end

      it "successfully updates citation counts" do
        expect(@subject.months.count).to eq(0)
        expect(@subject.perform_get_data).to eq(total: 31, html: 0, pdf: 0, previous_total: 0, skipped: false, update_interval: 31)
        expect(@subject.total).to eq(31)
        expect(@subject.months.count).to eq(1)
        expect(@subject.days.count).to eq(0)

        month = @subject.months.last
        expect(month.year).to eq(2015)
        expect(month.month).to eq(4)
        expect(month.total).to eq(31)
      end

      context "a subscriber milestone has been passed" do
        it "notifies subscribers" do
          subs = [
            {
              journal: 'pone',
              source: 'crossref',
              milestones: [1,15],
              url: 'https://example.com',
            }
          ]
          expect(@subject).to receive(:notify_subscriber).with('https://example.com', "10.1371/journal.pone.0053745", 1)
          expect(@subject).to receive(:get_subscribers).with('pone', 'crossref').and_return(subs) 
          expect(@subject).to receive(:notify_subscribers).with("10.1371/journal.pone.0053745", 'pone', 'crossref', 0, 31).and_call_original
          @subject.perform_get_data
        end
      end

      context "a subscriber milestone has NOT been passed" do
        it "does not notify subscribers" do
          subs = [
            {
              journal: 'pone',
              source: 'crossref',
              milestones: [40, 50],
              url: 'https://example-milestone-mismatch.com',
            },
            {
              journal: 'pmed',
              source: 'crossref',
              milestones: [1, 15],
              url: 'https://example-journal-mismatch.com',
            },
            {
              journal: 'pone',
              source: 'mendeley',
              milestones: [1, 15],
              url: 'https://example-source-mismatch.com',
            }
          ]
          expect(@subject).not_to receive(:notify_subscriber)
          expect(@subject).to receive(:get_subscribers).with('pone', 'crossref').and_return(subs)
          expect(@subject).to receive(:notify_subscribers).with("10.1371/journal.pone.0053745", 'pone', 'crossref', 0, 31).and_call_original
          @subject.perform_get_data
        end
      end
    end

    #TODO fix broken test
    xit "success article_coverage_curated" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0111913")
      relation_type = FactoryGirl.create(:relation_type, name: "discusses", title: "Discusses", inverse_name: "is_discussed_by")
      inverse_relation_type = FactoryGirl.create(:relation_type, name: "is_discussed_by", title: "Is discussed by", inverse_name: "discusses")
      source = FactoryGirl.create(:article_coverage_curated)
      subject = FactoryGirl.create(:retrieval_status, total: 0, comments: 0, work: work, source: source)

      expect(subject.months.count).to eq(0)
      expect(subject.perform_get_data).to eq(total: 17, html: 0, pdf: 0, previous_total: 0, skipped: false, update_interval: 31)
      expect(subject.total).to eq(17)
      expect(subject.months.count).to eq(5)
      expect(subject.days.count).to eq(0)

      month = subject.months.last
      expect(month.year).to eq(2015)
      expect(month.month).to eq(12)
      expect(month.total).to eq(1)

      expect(Work.count).to eq(16)
      related_work = Work.last
      expect(related_work.title).to eq("Plastic Smog: Microplastics Invade Our Oceans")
      expect(related_work.pid).to eq("http://ecowatch.com/2015/02/27/marcus-eriksen-microplastics-invade-oceans")
      expect(related_work.tracked).to be true

      expect(Relation.count).to eq(30)
      relation = Relation.first
      expect(relation.relation_type.name).to eq("discusses")
      expect(relation.source.name).to eq("article_coverage_curated")
      expect(relation.work.pid).to eq("http://www.nytimes.com/2014/12/11/science/new-research-quantifies-the-oceans-plastic-problem.html")
      expect(relation.related_work.pid).to eq(work.pid)

      expect(Alert.count).to eq(2)
      alert = Alert.first
      expect(alert.message).to eq("Validation failed: Published on is a date in the future for url http://www.popsci.com/five-trillion-pieces-plastic-are-floating-ocean-near-you-3.")
    end

    it "success no data" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0116034")
      subject = FactoryGirl.create(:retrieval_status, total: 2, readers: 2, work: work)

      expect(subject.months.count).to eq(0)
      expect(subject.perform_get_data).to eq(total: 0, html: 0, pdf: 0, previous_total: 2, skipped: false, update_interval: 31)
      expect(subject.total).to eq(0)
      expect(subject.readers).to eq(0)
      expect(subject.months.count).to eq(1)

      month = subject.months.last
      expect(month.year).to eq(2015)
      expect(month.month).to eq(4)
      expect(month.total).to eq(0)
      expect(month.readers).to eq(0)

      expect(Relation.count).to eq(0)
    end

    it "error (408)" do
      stub = stub_request(:get, subject.source.get_query_url(subject.work)).to_return(:status => [408])
      expect(subject.perform_get_data).to eq(total: 2, html: 0, pdf: 0, previous_total: 2, skipped: true, update_interval: 31)
      expect(subject.total).to eq(2)
      expect(subject.readers).to eq(2)
      expect(subject.months.count).to eq(0)
    end

    it "error (404)" do
      stub = stub_request(:get, subject.source.get_query_url(subject.work))
        .to_return(:status => [404], :body => 'server responded with 404')
      expect(subject.perform_get_data).to eq(total: 2, html: 0, pdf: 0, previous_total: 2, skipped: false, update_interval: 31)
      expect(subject.total).to eq(2)
      expect(subject.readers).to eq(2)
      expect(subject.months.count).to eq(1)
    end
  end

  describe "notify_subscriber" do
    it 'sends a request with relevant query params' do
      subject = FactoryGirl.create(:retrieval_status)

      expect(Faraday).to receive(:get).with('https://example.com/subscriber', {doi: '10.1371/pone.1234567', milestone: 42})
      subject.notify_subscriber('https://example.com/subscriber', '10.1371/pone.1234567', 42)
    end
  end

  describe "get_subscribers" do
    it "matches on journal and source" do
      subs = [
        {
          journal: 'pmed',
          source: 'crossref',
          milestones: [1, 15],
          url: 'https://example.com/pmed-xref',
        },
        {
          journal: 'pone',
          source: 'crossref',
          milestones: [1, 15],
          url: 'https://example.com/pone-xref',
        },
        {
          journal: 'pone',
          source: 'mendeley',
          milestones: [1, 15],
          url: 'https://example.com/pone-mend',
        }
      ]
      ::SUBSCRIBERS_CONFIG = {subscribers: subs}
      expect(subject.get_subscribers('pone', 'crossref').map{|s| s[:url]}).to eq(['https://example.com/pone-xref'])
      expect(subject.get_subscribers('pone', 'mendeley').map{|s| s[:url]}).to eq(['https://example.com/pone-mend'])
      expect(subject.get_subscribers('pmed', 'crossref').map{|s| s[:url]}).to eq(['https://example.com/pmed-xref'])
      expect(subject.get_subscribers('pbio', 'crossref')).to eq([])
    end
  end

end