require 'rails_helper'

describe RelativeMetric, type: :model, vcr: true do
  subject { FactoryGirl.create(:relative_metric) }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.build(:work, :doi => "10.4084/MJHID.2013.016")
      expect(subject.get_data(work)).to eq({})
    end

    it "should get relative metric average usage data" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0005723", :published_on => Date.new(2009, 5, 19))
      body = File.read(fixture_path + "relative_metric.json")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should get empty relative metric average usage data" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0000000", :published_on => Date.new(2009, 5, 19))
      body = File.read(fixture_path + "relative_metric_nodata.json")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the relative metric API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0047712")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:null_response) { { :events=>{:start_date=>"2009-01-01T00:00:00Z", :end_date=>"2009-12-31T00:00:00Z", :subject_areas=>[]}, :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>nil, :total=>0} } }

    it "should report if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil, :published_on => Date.new(2009, 5, 19))
      result = {}
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.build(:work, :doi => "10.5194/acp-12-12021-2012", :published_on => Date.new(2009, 5, 19))
      result = {}
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should get relative metric average usage data" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0005723", :published_on => Date.new(2009, 5, 19))
      body = File.read(fixture_path + "relative_metric.json")
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:events]).to eq(
        :start_date => "2009-01-01T00:00:00Z",
        :end_date => "2009-12-31T00:00:00Z",
        :subject_areas => [
          { :subject_area => "/Biology and life sciences", :average_usage => [745, 1364, 1546, 1784, 1976, 2125, 2249, 2361, 2447, 2489, 2530, 2579, 2606, 2634, 2655, 2668, 2697, 2730, 2777, 2821, 2849, 2882, 2898, 2912, 2927, 2935, 2942, 2966, 2984, 2997, 3008, 3035, 3059, 3078, 3098, 3112, 3124, 3151, 3169, 3182, 3188, 3196, 3221, 3252, 3283, 3319, 3327, 3338, 3348, 3362, 3383, 3403, 3414, 3423, 3448, 3478, 3496, 3516, 3537, 3547, 3558, 3576, 3600, 3655, 3672, 3677, 3694, 3703, 3708, 3711, 3718, 3728, 3743, 3760, 3773, 3793, 3813, 3822, 3833, 3854, 3874, 3892, 3902, 3915, 3940, 3958, 3974, 4030, 4084, 4140, 4190, 4228, 4280, 4322, 4379, 4435, 4457, 4483, 4505, 4524, 4556, 4570, 4604, 4639, 4651, 4661, 4683, 4704, 4717, 4736, 4763, 4782, 4815, 4825, 4839, 4856, 4906, 4914, 4925, 4945, 4960, 4979, 5073, 5091, 5102, 5116, 5139] },
          { :subject_area => "/Social sciences/Sociology", :average_usage => [382, 709, 869, 979, 1107, 1200, 1351, 1467, 1549, 1640, 1731, 1822, 1903, 1988, 2061, 2138, 2237, 2307, 2355, 2436, 2496, 2562, 2619, 2708, 2775, 2862, 2940, 2986, 3026, 3102, 3187, 3265, 3329, 3384, 3454, 3520, 3582, 3640, 3706, 3777, 3829, 3890, 3950, 4005, 4046] }
        ]
      )
      expect(response[:event_metrics]).to eq(:pdf => nil,
                                         :html => nil,
                                         :shares => nil,
                                         :groups => nil,
                                         :comments => nil,
                                         :likes => nil,
                                         :citations => nil,
                                         :total => 576895)
    end

    it "should get empty relative metric average usage data" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0000000", :published_on => Date.new(2009, 5, 19))
      body = File.read(fixture_path + "relative_metric_nodata.json")
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:events]).to eq(:start_date => "2009-01-01T00:00:00Z",
                                  :end_date => "2009-12-31T00:00:00Z",
                                  :subject_areas => [])
      expect(response[:event_metrics]).to eq(:pdf => nil,
                                         :html => nil,
                                         :shares => nil,
                                         :groups => nil,
                                         :comments => nil,
                                         :likes => nil,
                                         :citations => nil,
                                         :total => 0)
    end

    it "should catch timeout errors with the relative metric API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
