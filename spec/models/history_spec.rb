require 'rails_helper'

describe History, :type => :model do

  before(:each) do
    allow(Time).to receive(:now).and_return(Time.mktime(2014, 7, 5))
  end

  let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }

  context "error" do
    let(:data) { { error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/#{retrieval_status.work.doi_escaped}" } }
    let(:update_interval) { 30 }
    subject { History.new(retrieval_status.id, data) }

    it "should have status error" do
      expect(subject.status).to eq(:error)
    end

    it "should respond to an error" do
      expect(subject.to_hash).to eq(total: 0, html: 0, pdf: 0, previous_total: 50, skipped: true, update_interval: update_interval)
    end
  end

  context "success no data" do
    let(:data) { { total: 0 } }
    let(:update_interval) { 30 }
    subject { History.new(retrieval_status.id, data) }

    it "should have status success no data" do
      expect(subject.status).to eq(:success_no_data)
    end

    it "should respond to success with no data" do
      expect(subject.to_hash).to eq(total: 0, html: 0, pdf: 0, previous_total: 50, skipped: false, update_interval: update_interval)
    end
  end

  context "success" do
    let(:data) { { total: 25, events_by_day: [], events_by_month: [] } }
    let(:update_interval) { 30 }
    subject { History.new(retrieval_status.id, data) }

    it "should have status success" do
      expect(subject.status).to eq(:success)
    end

    it "should respond to success" do
      expect(subject.to_hash).to eq(total: 25, html: 0, pdf: 0, previous_total: 50, skipped: false, update_interval: update_interval)
    end
  end

  context "events_current_day" do
    let(:today) { Time.zone.now.to_date }
    let(:yesterday) { Time.zone.now.to_date - 1.day }
    let(:data) { { total: 25, events_by_day: nil } }
    subject { History.new(retrieval_status.id, data) }

    context "recent works from crossref" do
      let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :with_crossref_and_work_published_today) }

      it "should generate events by day for recent works" do
        expect(subject.get_events_current_day).to eq(year: today.year, month: today.month, day: today.day, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total])
      end

      it "should add to events by day for recent works" do
        retrieval_status = FactoryGirl.create(:retrieval_status, :with_crossref_last_day)
        expect(subject.get_events_current_day).to eq(year: today.year, month: today.month, day: today.day, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total] - 25)
      end

      it "should update events by day for recent works" do
        retrieval_status = FactoryGirl.create(:retrieval_status, :with_crossref_current_day)
        expect(subject.get_events_current_day).to eq(year: today.year, month: today.month, day: today.day, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total])
      end
    end

    context "recent works from counter" do
      let(:data) { { total: 750, html: 600, pdf: 150, events_by_day: nil } }
      let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :with_counter_and_work_published_today) }

      it "should generate events by day for recent works" do
        expect(subject.get_events_current_day).to eq(year: today.year, month: today.month, day: today.day, html: data[:html], pdf: data[:pdf], readers: 0, comments: 0, likes: 0, total: data[:total])
      end

      it "should add to events by day for recent works" do
        retrieval_status = FactoryGirl.create(:retrieval_status, :with_counter_last_day)
        pp subject.get_events_previous_day
        expect(subject.get_events_current_day).to eq(year: today.year, month: today.month, day: today.day, html: 200, pdf: 50, readers: 0, comments: 0, likes: 0, total: 250)
      end

      it "should update events by day for recent works" do
        retrieval_status = FactoryGirl.create(:retrieval_status, :with_counter_current_day)
        expect(subject.get_events_current_day).to eq(year: today.year, month: today.month, day: today.day, html: data[:html], pdf: data[:pdf], readers: 0, comments: 0, likes: 0, total: data[:total])
      end
    end

    context "old works" do
      it "should return an empty array for old works" do
        expect(subject.get_events_current_day).to be_nil
      end
    end
  end

  context "events_current_month" do
    let(:data) { { total: 30, events_by_month: nil } }
    let(:today) { Time.zone.now.to_date }
    let(:last_month) { Time.zone.now.to_date - 1.month }
    subject { History.new(retrieval_status.id, data) }

    context "recent works from crossref" do
      let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :with_crossref_and_work_published_today) }

      it "should generate events by month" do
        expect(subject.get_events_current_month).to eq(year: today.year, month: today.month, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total])
      end

      it "should update events by month" do
        retrieval_status = FactoryGirl.create(:retrieval_status, :with_crossref_current_month)
        expect(subject.get_events_current_month).to eq(year: today.year, month: today.month, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total])
      end
    end

    context "older works from crossref" do
      let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :with_crossref) }

      it "should generate events by month" do
        expect(subject.get_events_current_month).to eq(year: today.year, month: today.month, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total])
      end

      it "should add to events by month" do
        retrieval_status = FactoryGirl.create(:retrieval_status, :with_crossref_last_month)
        expect(subject.get_events_current_month).to eq(year: today.year, month: today.month, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total] - 25)
      end

      it "should update events by month" do
        retrieval_status = FactoryGirl.create(:retrieval_status, :with_crossref_current_month)
        expect(subject.get_events_current_month).to eq(year: today.year, month: today.month, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: data[:total])
      end
    end
  end
end
