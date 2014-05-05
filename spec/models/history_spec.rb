require 'spec_helper'

describe History do

  let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }

  context "error" do
    let(:data) { { error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/#{retrieval_status.article.doi_escaped}" } }
    subject { History.new(retrieval_status.id, data) }

    it "should have status error" do
      subject.status.should eq(:error)
    end

    it "should not create a retrieval_history record" do
      subject.retrieval_history.should be_nil
    end

    it "should respond to an error" do
      subject.to_hash.should eq(event_count: nil, previous_count: 50, retrieval_history_id: nil, update_interval: 30)
    end
  end

  context "success no data" do
    let(:data) { { event_count: 0 } }
    subject { History.new(retrieval_status.id, data) }

    it "should have status success no data" do
      subject.status.should eq(:success_no_data)
    end

    it "should create a retrieval_history record" do
      subject.retrieval_history.event_count.should eq(data[:event_count])
    end

    #
    it "should respond to success with no data" do
      subject.to_hash.should eq(event_count: 0, previous_count: 50, retrieval_history_id: subject.retrieval_history.id, update_interval: 30)
    end
  end

  context "success" do
    before(:each) { subject.put_alm_database }
    after(:each) { subject.delete_alm_database }

    let(:data) { { event_count: 25, events_by_day: [], events_by_month: [] } }
    subject { History.new(retrieval_status.id, data) }

    it "should have status success" do
      subject.status.should eq(:success)
    end

    it "should create a retrieval_history record" do
      subject.retrieval_history.event_count.should eq(data[:event_count])
    end

    it "should respond to success" do
      subject.to_hash.should eq(event_count: 25, previous_count: 50, retrieval_history_id: subject.retrieval_history.id, update_interval: 30)
    end

    # it "should store data in CouchDB" do
    #   subject.to_hash.should eq(event_count: 25, previous_count: 50, retrieval_history_id: subject.retrieval_history.id, update_interval: 30)
    #   subject.rs_rev.should be_nil
    #   subject.rh_rev.should be_nil
    # end
  end

  context "events_by_day" do
    before(:each) { subject.put_alm_database }
    after(:each) { subject.delete_alm_database }

    let(:data) { { event_count: 25, events_by_day: nil, event_metrics: { html: 15, pdf: 5, total: 25 } } }
    let(:today) { Time.zone.now.to_date }
    let(:yesterday) { Time.zone.now.to_date - 1.day }
    subject { History.new(retrieval_status.id, data) }

    context "recent articles from crossref" do
      let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :with_crossref_and_article_published_today) }

      it "should generate events by day for recent articles" do
        events_by_day = nil
        subject.get_events_by_day(events_by_day).should eq([{ 'year' => today.year, 'month' => today.month, 'day' => today.day, 'total' => data[:event_count] }])
      end

      it "should add to events by day for recent articles" do
        events_by_day = [{ 'year' => yesterday.year, 'month' => yesterday.month, 'day' => yesterday.day, 'total' => 3 }]
        subject.get_events_by_day(events_by_day).should eq([events_by_day[0],
                                                           { 'year' => today.year, 'month' => today.month, 'day' => today.day, 'total' => data[:event_count] - 3 }])
      end

      it "should update events by day for recent articles" do
        events_by_day = [{ 'year' => today.year, 'month' => today.month, 'day' => today.day, 'total' => 3 }]
        subject.get_events_by_day(events_by_day).should eq([{ 'year' => today.year, 'month' => today.month, 'day' => today.day, 'total' => data[:event_count] }])
      end
    end

    context "recent articles from counter" do
      let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :with_counter_and_article_published_today) }

      it "should generate events by day for recent articles" do
        events_by_day = nil
        subject.get_events_by_day(events_by_day).should eq([{ 'year' => today.year, 'month' => today.month, 'day' => today.day, 'html' => data[:event_metrics][:html], 'pdf' => data[:event_metrics][:pdf] }])
      end

      it "should add to events by day for recent articles" do
        events_by_day = [{ 'year' => yesterday.year, 'month' => yesterday.month, 'day' => yesterday.day, 'html' => 12, 'pdf' => 4 }]
        subject.get_events_by_day(events_by_day).should eq([events_by_day[0],
                                                            { 'year' => today.year, 'month' => today.month, 'day' => today.day, 'html' => data[:event_metrics][:html] - 12, 'pdf' => data[:event_metrics][:pdf] - 4 }])
      end

      it "should update events by day for recent articles" do
        events_by_day = [{ 'year' => today.year, 'month' => today.month, 'day' => today.day, 'total' => 3 }]
        subject.get_events_by_day(events_by_day).should eq([{ 'year' => today.year, 'month' => today.month, 'day' => today.day, 'html' => data[:event_metrics][:html], 'pdf' => data[:event_metrics][:pdf] }])
      end
    end

    context "old articles" do
      it "should return events by day for old articles" do
        events_by_day = [{ 'year' => today.year - 1, 'month' => today.month, 'day' => today.day, 'total' => data[:event_count] }]
        subject.get_events_by_day(events_by_day).should eq(events_by_day)
      end

      it "should return events by day for old articles, turning nil into an empty array" do
        subject.get_events_by_day(data[:events_by_day]).should eq(Array(data[:events_by_day]))
      end
    end
  end

  context "events_by_month" do
    before(:each) { subject.put_alm_database }
    after(:each) { subject.delete_alm_database }

    let(:data) { { event_count: 25, events_by_month: nil, event_metrics: { html: 15, pdf: 5, total: 25 } } }
    let(:today) { Time.zone.now.to_date }
    let(:last_month) { Time.zone.now.to_date - 1.month }
    subject { History.new(retrieval_status.id, data) }

    context "recent articles from crossref" do
      let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :with_crossref_and_article_published_today) }

      it "should generate events by month" do
        events_by_month = nil
        subject.get_events_by_month(events_by_month).should eq([{ 'year' => today.year, 'month' => today.month, 'total' => data[:event_count] }])
      end

      it "should update events by month" do
        events_by_month = [{ 'year' => today.year, 'month' => today.month, 'total' => 3 }]
        subject.get_events_by_month(events_by_month).should eq([{ 'year' => today.year, 'month' => today.month, 'total' => data[:event_count] }])
      end
    end

    context "older articles from crossref" do
      let(:retrieval_status) { FactoryGirl.create(:retrieval_status, :with_crossref) }

      it "should generate events by month" do
        events_by_month = nil
        subject.get_events_by_month(events_by_month).should eq([{ 'year' => today.year, 'month' => today.month, 'total' => data[:event_count] }])
      end

      it "should add to events by month" do
        events_by_month = [{ 'year' => last_month.year, 'month' => last_month.month, 'total' => 3 }]
        subject.get_events_by_month(events_by_month).should eq([events_by_month[0],
                                                               { 'year' => today.year, 'month' => today.month, 'total' => data[:event_count] - 3 }])
      end

      it "should update events by month" do
        events_by_month = [{ 'year' => last_month.year, 'month' => last_month.month, 'total' => 3 }, { 'year' => today.year, 'month' => today.month, 'total' => 10 }]
        subject.get_events_by_month(events_by_month).should eq([events_by_month[0],
                                                               { 'year' => today.year, 'month' => today.month, 'total' => data[:event_count] - 3 }])
      end

      it "should update events by month without previous month" do
        events_by_month = [{ 'year' => today.year, 'month' => today.month, 'total' => 0 }]
        subject.get_events_by_month(events_by_month).should eq([{ 'year' => today.year, 'month' => today.month, 'total' => data[:event_count] }])
      end
    end
  end
end
