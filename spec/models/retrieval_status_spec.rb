require 'rails_helper'

describe RetrievalStatus, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  it { is_expected.to belong_to(:work) }
  it { is_expected.to belong_to(:source) }

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
      expect(subject.get_events_current_day).to eq(year: 2013, month: 9, day: 5, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 25)
    end

    it "current day" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref_current_day)
      expect(subject.get_events_current_day).to eq(year: 2013, month: 9, day: 5, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 20)
    end

    it "last day" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref_last_day)
      expect(subject.get_events_current_day).to eq(year: 2013, month: 9, day: 5, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 5)
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
      expect(subject.get_events_current_month).to eq(year: 2013, month: 9, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 25)
    end

    it "current month" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref_current_month)
      expect(subject.get_events_current_month).to eq(year: 2013, month: 9, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 20)
    end

    it "last month" do
      subject = FactoryGirl.create(:retrieval_status, :with_crossref_last_month)
      expect(subject.get_events_current_month).to eq(year: 2013, month: 9, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 5)
    end
  end

  describe "update_works" do
    subject { FactoryGirl.create(:retrieval_status, :with_crossref) }

    it "no works" do
      data = []
      expect(subject.update_works(data)).to be_empty
    end

    it "work from CrossRef" do
      related_work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0043007")
      relation_type = FactoryGirl.create(:relation_type)
      data = [{"author"=>[{"family"=>"Occelli", "given"=>"Valeria"}, {"family"=>"Spence", "given"=>"Charles"}, {"family"=>"Zampini", "given"=>"Massimiliano"}], "title"=>"Audiotactile Interactions In Temporal Perception", "container-title"=>"Psychonomic Bulletin & Review", "issued"=>{"date-parts"=>[[2011]]}, "DOI"=>"10.3758/s13423-011-0070-4", "volume"=>"18", "issue"=>"3", "page"=>"429", "type"=>"article-journal", "related_works"=>[{"related_work"=>"doi:10.1371/journal.pone.0043007", "source"=>"crossref", "relation_type"=>"cites"}]}]
      expect(subject.update_works(data)).to eq(["doi:10.3758/s13423-011-0070-4"])

      expect(Work.count).to eq(4)
      work = Work.last
      expect(work.title).to eq("Audiotactile Interactions In Temporal Perception")
      expect(work.pid).to eq("doi:10.3758/s13423-011-0070-4")

      expect(work.events.length).to eq(1)
      expect(work.events.first.relation_type.name).to eq(relation_type.name)

      expect(work.related_works.length).to eq(1)
      expect(work.related_works.first).to eq(related_work)
    end
  end

  # context "perform_get_data with error" do
  #   let(:data) { { error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/#{retrieval_status.work.doi_escaped}" } }
  #   let(:update_interval) { 30 }
  #   subject { let(:retrieval_status) { FactoryGirl.create(:retrieval_status) } }

  #   it "should have status error" do
  #     expect(subject.status).to eq(:error)
  #   end

  #   it "should respond to an error" do
  #     expect(subject.to_hash).to eq(total: 0, html: 0, pdf: 0, previous_total: 50, skipped: true, update_interval: update_interval)
  #   end
  # end

  # context "success no data" do
  #   let(:data) { { total: 0 } }
  #   let(:update_interval) { 30 }
  #   subject { History.new(retrieval_status.id, data) }

  #   it "should have status success no data" do
  #     expect(subject.status).to eq(:success_no_data)
  #   end

  #   it "should respond to success with no data" do
  #     expect(subject.to_hash).to eq(total: 0, html: 0, pdf: 0, previous_total: 50, skipped: false, update_interval: update_interval)
  #   end
  # end

  # context "success" do
  #   let(:data) { { total: 25, events_by_day: [], events_by_month: [] } }
  #   let(:update_interval) { 30 }
  #   subject { History.new(retrieval_status.id, data) }

  #   it "should have status success" do
  #     expect(subject.status).to eq(:success)
  #   end

  #   it "should respond to success" do
  #     expect(subject.to_hash).to eq(total: 25, html: 0, pdf: 0, previous_total: 50, skipped: false, update_interval: update_interval)
  #   end
  # end

  # context "events_current_day" do
  #   let(:today) { Time.zone.now.to_date }
  #   let(:yesterday) { Time.zone.now.to_date - 1.day }
  #   let(:data) { { total: 25, events_by_day: nil } }
  #   subject { History.new(retrieval_status.id, data) }

  #   context "recent works from crossref" do
  #     let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :with_crossref_and_work_published_today) }

  #     it "should generate events by day for recent works" do
  #       expect(subject.get_events_current_day).to eq(year: today.year, month: today.month, day: today.day, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total])
  #     end

  #     it "should add to events by day for recent works" do
  #       retrieval_status = FactoryGirl.create(:retrieval_status, :with_crossref_last_day)
  #       expect(subject.get_events_current_day).to eq(year: today.year, month: today.month, day: today.day, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total] - 25)
  #     end

  #     it "should update events by day for recent works" do
  #       retrieval_status = FactoryGirl.create(:retrieval_status, :with_crossref_current_day)
  #       expect(subject.get_events_current_day).to eq(year: today.year, month: today.month, day: today.day, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total])
  #     end
  #   end

  #   context "recent works from counter" do
  #     let(:data) { { total: 750, html: 600, pdf: 150, events_by_day: nil } }
  #     let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :with_counter_and_work_published_today) }

  #     it "should generate events by day for recent works" do
  #       expect(subject.get_events_current_day).to eq(year: today.year, month: today.month, day: today.day, html: data[:html], pdf: data[:pdf], readers: 0, comments: 0, likes: 0, total: data[:total])
  #     end

  #     it "should add to events by day for recent works" do
  #       retrieval_status = FactoryGirl.create(:retrieval_status, :with_counter_last_day)
  #       pp subject.get_events_previous_day
  #       expect(subject.get_events_current_day).to eq(year: today.year, month: today.month, day: today.day, html: 200, pdf: 50, readers: 0, comments: 0, likes: 0, total: 250)
  #     end

  #     it "should update events by day for recent works" do
  #       retrieval_status = FactoryGirl.create(:retrieval_status, :with_counter_current_day)
  #       expect(subject.get_events_current_day).to eq(year: today.year, month: today.month, day: today.day, html: data[:html], pdf: data[:pdf], readers: 0, comments: 0, likes: 0, total: data[:total])
  #     end
  #   end

  #   context "old works" do
  #     it "should return an empty array for old works" do
  #       expect(subject.get_events_current_day).to be_nil
  #     end
  #   end
  # end

  # context "events_current_month" do
  #   let(:data) { { total: 30, events_by_month: nil } }
  #   let(:today) { Time.zone.now.to_date }
  #   let(:last_month) { Time.zone.now.to_date - 1.month }
  #   subject { History.new(retrieval_status.id, data) }

  #   context "recent works from crossref" do
  #     let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :with_crossref_and_work_published_today) }

  #     it "should generate events by month" do
  #       expect(subject.get_events_current_month).to eq(year: today.year, month: today.month, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total])
  #     end

  #     it "should update events by month" do
  #       retrieval_status = FactoryGirl.create(:retrieval_status, :with_crossref_current_month)
  #       expect(subject.get_events_current_month).to eq(year: today.year, month: today.month, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total])
  #     end
  #   end

  #   context "older works from crossref" do
  #     let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :with_crossref) }

  #     it "should generate events by month" do
  #       expect(subject.get_events_current_month).to eq(year: today.year, month: today.month, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total])
  #     end

  #     it "should add to events by month" do
  #       retrieval_status = FactoryGirl.create(:retrieval_status, :with_crossref_last_month)
  #       expect(subject.get_events_current_month).to eq(year: today.year, month: today.month, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total] - 25)
  #     end

  #     it "should update events by month" do
  #       retrieval_status = FactoryGirl.create(:retrieval_status, :with_crossref_current_month)
  #       expect(subject.get_events_current_month).to eq(year: today.year, month: today.month, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total])
  #     end
  #   end
  # end
end
