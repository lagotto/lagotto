require "spec_helper"

describe "/api/v5/articles" do

  context "private source" do
    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:article) { FactoryGirl.create(:article_with_private_citations) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&api_key=#{user.api_key}"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        response["total"].should == 1
        item = response["data"].first
        item["doi"].should eql(article.doi)
        item["publication_date"].should eq(article.published_on.to_time.utc.iso8601)
        item_source = item["sources"][0]
        item_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        item_source["metrics"].should include("citations")
        item_source["metrics"]["shares"].should eq(article.retrieval_statuses.first.event_count)
        item_source["metrics"].should include("comments")
        item_source["metrics"].should include("groups")
        item_source["metrics"].should include("html")
        item_source["metrics"].should include("likes")
        item_source["metrics"].should include("pdf")
        item_source["events"].should be_nil
        item_source["histories"].should be_nil
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }
      let(:article) { FactoryGirl.create(:article_with_private_citations) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&api_key=#{user.api_key}"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        response["total"].should == 1
        item = response["data"].first
        item["doi"].should eql(article.doi)
        item["publication_date"].should eq(article.published_on.to_time.utc.iso8601)
        item_source = item["sources"][0]
        item_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        item_source["metrics"].should include("citations")
        item_source["metrics"]["shares"].should eq(article.retrieval_statuses.first.event_count)
        item_source["metrics"].should include("comments")
        item_source["metrics"].should include("groups")
        item_source["metrics"].should include("html")
        item_source["metrics"].should include("likes")
        item_source["metrics"].should include("pdf")
        item_source["events"].should be_nil
        item_source["histories"].should be_nil
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }
      let(:article) { FactoryGirl.create(:article_with_private_citations) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&api_key=#{user.api_key}"}
      let(:nothing_found) {{ "total" => 0, "total_pages" => 0, "page" => 0, "error" => nil, "data" => [] }}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200
        last_response.body.should eq(nothing_found.to_json)
      end
    end
  end
end