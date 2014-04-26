require 'spec_helper'

describe Twitter do
  let(:twitter) { FactoryGirl.create(:twitter) }

  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    twitter.parse_data(article_without_doi).should eq(events: [], event_count: nil)
  end

  context "use the Twitter API" do
    it "should report if there are events and event_count returned by the Twitter API" do
      article = FactoryGirl.build(:article, :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pmed.0020124")
      stub = stub_request(:get, twitter.get_query_url(article)).to_return(:headers => {"Content-Type" => "application/json"}, :body => File.read(fixture_path + 'twitter.json'), :status => 200)
      response = twitter.parse_data(article)
      response[:event_count].should eq(2)

      event = response[:events].first
      event_data = event[:event]

      event_data[:id].should eq("204270013081849857")
      event_data[:text].should eq("Don't be blinded by science http://t.co/YOWRhsXb")
      event_data[:created_at].should eq("Sun, 20 May 2012 17:59:00 +0000")
      event_data[:user].should eq("regrum")
      event_data[:user_name].should eq("regrum")
      event_data[:user_profile_image].should eq("http://a0.twimg.com/profile_images/61215276/regmanic2_normal.JPG")

      event[:event_url].should eq("http://twitter.com/regrum/status/204270013081849857")

      event = response[:events][1]
      event_data = event[:event]

      event_data[:id].should eq("204762721751797761")
      event_data[:text].should eq("@chris_stevenson seen this? Why Most Published Research Findings Are False http://t.co/5yDXdbcz")
      event_data[:created_at].should eq("Tue May 22 02:36:51 +0000 2012")
      event_data[:user].should eq("manderbabble")
      event_data[:user_name].should eq("manderbabble")
      event_data[:user_profile_image].should eq("http://a0.twimg.com/profile_images/504862320/zardoz_normal.jpg")

      event[:event_url].should eq("http://twitter.com/manderbabble/status/204762721751797761")
    end

  end

end
