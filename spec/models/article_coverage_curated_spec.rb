require 'spec_helper'

describe ArticleCoverageCurated do
  let(:article_coverage_curated) { FactoryGirl.create(:article_coverage_curated) }

  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    article_coverage_curated.parse_data(article_without_doi).should eq(events: [], event_count: nil)
  end

  context "use the Article Coverage Curated API" do
    context "use article without events" do

      it "should report if article doesn't exist in Article Coverage Curated source" do
        article_without_events = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
        stub = stub_request(:get, article_coverage_curated.get_query_url(article_without_events))
        .to_return(:headers => {"Content-Type" => "application/json"}, :body => {"error" => "Article not found"}.to_json, :status => 404)
        article_coverage_curated.parse_data(article_without_events).should eq(events: [], event_count: 0)
        stub.should have_been_requested
      end

      it "should report if there are no events and event_count returned by the Article Coverage Curated API" do
        article_without_events = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008775")
        stub = stub_request(:get, article_coverage_curated.get_query_url(article_without_events))
          .to_return(:headers => {"Content-Type" => "application/json"}, :body => File.read(fixture_path + 'article_coverage_curated_nil.json'), :status => 200)
        article_coverage_curated.parse_data(article_without_events).should eq(events: [], event_count: 0)
        stub.should have_been_requested
      end
    end

    context "use article with events" do
      let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0047712") }

      it "should report if there are events and event_count returned by the Article Coverage Curated API" do
        stub = stub_request(:get, article_coverage_curated.get_query_url(article))
          .to_return(:headers => {"Content-Type" => "application/json"}, :body => File.read(fixture_path + 'article_coverage_curated.json'), :status => 200)
        response = article_coverage_curated.parse_data(article)
        response[:events].length.should eq(15)
        response[:event_count].should eq(15)
        event = response[:events].first
        event_data = event[:event]
        event_data['referral'].should eq("http://www.wildlifeofyourbody.org/?page_id=1348")
        event_data['language'].should eq("English")
        event_data['title'].should eq("Project Description @ Belly Button Biodiversity")
        event_data['type'].should eq("Blog")
        event_data['publication'].should eq("")
        event_data['published_on'].should eq("")
        event_data['link_state'].should eq("")

        event[:event_url].should eq("http://www.wildlifeofyourbody.org/?page_id=1348")

        stub.should have_been_requested
      end
    end
  end
end
