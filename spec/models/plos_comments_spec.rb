require 'spec_helper'

describe PlosComments do
  subject { FactoryGirl.create(:plos_comments) }

  let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0067729") }

  context "use the PLOS comments API" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      subject.get_data(article).should eq({})
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      article = FactoryGirl.build(:article, :doi => "10.5194/acp-12-12021-2012")
      subject.get_data(article).should eq({})
    end

    it "should report if the article was not found by the PLOS comments API" do
      body = File.read(fixture_path + 'plos_comments_error.txt')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body, :status => 404)
      response = subject.get_data(article)
      response.should eq(error: body)
      stub.should have_been_requested
    end

    it "should report if there are no events and event_count returned by the PLOS comments API" do
      body = File.read(fixture_path + 'plos_comments_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq('data' => JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the PLOS comments API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'plos_comments.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq('data' => JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch timeout errors with the PLOS comments API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 408 for http://example.org?doi={doi}")
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    let(:null_response) { { :events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>0, :likes=>nil, :citations=>nil, :total=>0 } } }

    it "should report if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      result = {}
      subject.parse_data(result, article).should eq(null_response)
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      article = FactoryGirl.build(:article, :doi => "10.5194/acp-12-12021-2012")
      result = {}
      subject.parse_data(result, article).should eq(null_response)
    end

    it "should report if the article was not found by the PLOS comments API" do
      result = { error: File.read(fixture_path + 'plos_comments_error.txt') }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end

    it "should report if there are no events and event_count returned by the PLOS comments API" do
      body = File.read(fixture_path + 'plos_comments_nil.json')
      result = { 'data' => JSON.parse(body) }
      subject.parse_data(result, article).should eq(null_response)
    end

    it "should report if there are events and event_count returned by the PLOS comments API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124", published_on: "2009-03-15")
      body = File.read(fixture_path + 'plos_comments.json')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, article)
      response[:event_count].should == 36
      response[:event_metrics].should eq(pdf: nil, html: nil, shares: nil, groups: nil, comments: 31, likes: nil, citations: nil, total: 36)

      response[:events_by_day].length.should eq(2)
      response[:events_by_day].first.should eq(year: 2009, month: 3, day: 30, total: 7)
      response[:events_by_month].length.should eq(9)
      response[:events_by_month].first.should eq(year: 2009, month: 3, total: 21)

      event = response[:events].last

      event[:event_csl]['author'].should eq([{"family"=>"Samigulina", "given"=>"Gulnara"}])
      event[:event_csl]['title'].should eq("A small group research.")
      event[:event_csl]['container-title'].should eq("PLOS Comments")
      event[:event_csl]['issued'].should eq("date_parts"=>[2013, 10, 27])
      event[:event_csl]['type'].should eq("personal_communication")

      event[:event_time].should eq("2013-10-27T22:03:35Z")
      event[:event]["totalNumReplies"].should == 0
    end

    it "should catch timeout errors with the PLOS comments API" do
      article = FactoryGirl.create(:article, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://example.org?doi={doi}" }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
