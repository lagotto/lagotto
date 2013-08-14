require 'spec_helper'
require 'source_helper'
require 'nori'

class SourceHelperClass
end

describe SourceHelper do

  before(:each) do
    @source_helper_class = SourceHelperClass.new
    @source_helper_class.extend(SourceHelper)
  end

  context "HTTP" do
    let(:article) { FactoryGirl.create(:article_with_events) }
    let(:url) { "http://127.0.0.1/api/v3/articles/info:doi/#{article.doi}"}
    let(:data) { { "name" => "Fred"} }

    context "response" do
      it "get_json" do
        stub = stub_request(:get, url).to_return(:body => data.to_json, :content_type => 'application/json', :status => 200)
        response = @source_helper_class.get_json(url)
        response.should eq(data)
      end

      it "get_xml" do
        stub = stub_request(:get, url).to_return(:body => data.to_xml, :content_type => 'application/xml', :status => 200)
        @source_helper_class.get_xml(url) { |response| Nori.new.parse(response.to_s)["hash"].should eq(data) }
      end
    end

    context "empty response" do
      it "get_json" do
        stub = stub_request(:get, url).to_return(:body => nil, :content_type => 'application/json', :status => 200)
        response = @source_helper_class.get_json(url)
        response.should be_nil
      end

      it "get_xml" do
        stub = stub_request(:get, url).to_return(:body => nil, :content_type => 'application/xml', :status => 200)
        @source_helper_class.get_xml(url) { |response| response.should be_nil }
      end
    end

    context "not found" do
      let(:error) { { "error" => "Not Found"} }

      it "get_json" do
        stub = stub_request(:get, url).to_return(:body => error.to_json, :content_type => 'application/json', :status => [404, "Not Found"])
        @source_helper_class.get_json(url).should eq(error)
        ErrorMessage.count.should == 0
      end

      it "get_xml" do
        stub = stub_request(:get, url).to_return(:body => error.to_xml, :content_type => 'application/xml', :status => [404, "Not Found"])
        @source_helper_class.get_xml(url) { |response| Nori.new.parse(response.to_s)["hash"].should eq(error) }
        ErrorMessage.count.should == 0
      end
    end

    context "request timeout" do
      let(:error) { { "error" => "Request Timeout"} }

      it "get_json" do
        stub = stub_request(:get, url).to_return(:body => error.to_json, :content_type => 'application/json', :status => [408, "Request Timeout"])
        @source_helper_class.get_json(url).should be_nil
        ErrorMessage.count.should == 1
        error_message = ErrorMessage.first
        error_message.class_name.should eq("Net::HTTPRequestTimeOut")
        error_message.message.should include("Request Timeout")
        error_message.status.should == 408
      end

      it "get_xml" do
        stub = stub_request(:get, url).to_return(:body => error.to_json, :content_type => 'application/json', :status => [408, "Request Timeout"])
        @source_helper_class.get_xml(url) { |response| response.should be_nil }
        ErrorMessage.count.should == 1
        error_message = ErrorMessage.first
        error_message.class_name.should eq("Net::HTTPRequestTimeOut")
        error_message.message.should include("Request Timeout")
        error_message.status.should == 408
      end
    end

    context "request timeout internal" do
      let(:error) { { "error" => "Request Timeout"} }

      it "get_json" do
        stub = stub_request(:get, url).to_timeout
        @source_helper_class.get_json(url).should be_nil
        ErrorMessage.count.should == 1
        error_message = ErrorMessage.first
        error_message.class_name.should eq("Net::HTTPRequestTimeOut")
        error_message.message.should include("Request Timeout")
        error_message.status.should == 408
      end

      it "get_xml" do
        stub = stub_request(:get, url).to_timeout
        @source_helper_class.get_xml(url) { |response| response.should be_nil }
        ErrorMessage.count.should == 1
        error_message = ErrorMessage.first
        error_message.class_name.should eq("Net::HTTPRequestTimeOut")
        error_message.message.should include("Request Timeout")
        error_message.status.should == 408
      end
    end

    context "too many requests" do
      let(:error) { { "error" => "Too Many Requests"} }

      it "get_json" do
        stub = stub_request(:get, url).to_return(:body => error.to_json, :content_type => 'application/json', :status => [429, "Too Many Requests"])
        @source_helper_class.get_json(url).should be_nil
        ErrorMessage.count.should == 1
        error_message = ErrorMessage.first
        error_message.class_name.should eq("Net::HTTPClientError")
        error_message.message.should include("Too Many Requests")
        error_message.status.should == 429
      end

      it "get_xml" do
        stub = stub_request(:get, url).to_return(:body => error.to_xml, :content_type => 'application/xml', :status => [429, "Too Many Requests"])
        @source_helper_class.get_xml(url) { |response| response.should be_nil }
        ErrorMessage.count.should == 1
        error_message = ErrorMessage.first
        error_message.class_name.should eq("Net::HTTPClientError")
        error_message.message.should include("Too Many Requests")
        error_message.status.should == 429
      end
    end

    context "store source_id with error" do
      let(:error) { { "error" => "Too Many Requests"} }

      it "get_json" do
        stub = stub_request(:get, url).to_return(:body => error.to_json, :content_type => 'application/json', :status => [429, "Too Many Requests"])
        @source_helper_class.get_json(url, :source_id => 1).should be_nil
        ErrorMessage.count.should == 1
        error_message = ErrorMessage.first
        error_message.class_name.should eq("Net::HTTPClientError")
        error_message.message.should include("Too Many Requests")
        error_message.status.should == 429
        error_message.source_id.should == 1
      end

      it "get_xml" do
        stub = stub_request(:get, url).to_return(:body => error.to_xml, :content_type => 'application/xml', :status => [429, "Too Many Requests"])
        @source_helper_class.get_xml(url, :source_id => 1) { |response| response.should be_nil }
        ErrorMessage.count.should == 1
        error_message = ErrorMessage.first
        error_message.class_name.should eq("Net::HTTPClientError")
        error_message.message.should include("Too Many Requests")
        error_message.source_id.should == 1
      end
    end

    context "original URL" do

      it "get_original_url" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000030"
        stub = stub_request(:head, "http://dx.doi.org/#{article.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:head, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = @source_helper_class.get_original_url(article.doi)
        response.should eq(url)
        ErrorMessage.count.should == 0
        stub.should have_been_requested
      end

      it "get_original_url with cookies" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1080/10629360600569196")
        url = "http://www.tandfonline.com/doi/abs/10.1080/10629360600569196"
        stub = stub_request(:head, "http://dx.doi.org/#{article.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:head, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = @source_helper_class.get_original_url(article.doi)
        response.should eq(url)
        ErrorMessage.count.should == 0
        stub.should have_been_requested
      end

      it "get_original_url with not found error" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        stub = stub_request(:head, "http://dx.doi.org/#{article.doi}").to_return(:status => 404)
        response = @source_helper_class.get_original_url(article.doi)
        response.should eq("")
        ErrorMessage.count.should == 0
        stub.should have_been_requested
      end

      it "get_original_url with timeout error" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        stub = stub_request(:head, "http://dx.doi.org/#{article.doi}").to_return(:status => [408, "Request Timeout"])
        response = @source_helper_class.get_original_url(article.doi)
        response.should eq("")
        ErrorMessage.count.should == 1
        error_message = ErrorMessage.first
        error_message.class_name.should eq("Faraday::Response")
        error_message.message.should include("Could not get the full URL")
        error_message.status.should == 408
        stub.should have_been_requested
      end
    end
  end

  context "CouchDB" do
    before(:each) do
      @source_helper_class.put_alm_database
    end

    after(:each) do
      @source_helper_class.delete_alm_database
    end

    let(:id) { "test" }
    let(:url) { "#{APP_CONFIG['couchdb_url']}#{id}" }
    let(:data) { { "name" => "Fred"} }
    let(:error) { {"error"=>"not_found", "reason"=>"missing"} }

    it "put, get and delete data" do
      put_response = @source_helper_class.put_alm_data(url, data.to_json)
      put_response.should be_a_kind_of(Net::HTTPCreated)
      put_body = ActiveSupport::JSON.decode(put_response.body)
      rev = put_body["rev"]
      put_body.should include("ok" => true, "id" => id)

      get_response = @source_helper_class.get_alm_data(id)
      get_response.should include("_id" => id, "_rev" => rev)

      get_info = @source_helper_class.get_alm_database
      db_name = URI.parse(APP_CONFIG['couchdb_url']).path[1..-2]
      get_info["db_name"].should eq(db_name)
      get_info["disk_size"].should be > 0
      get_info["doc_count"].should eq(1)

      new_rev = @source_helper_class.save_alm_data(rev, data, id)
      new_rev.should_not eq(rev)

      delete_response = @source_helper_class.remove_alm_data(new_rev, id)
      delete_response.should include("3-")
    end

    it "handle revisions" do
      rev = @source_helper_class.save_alm_data(nil, data, id)
      new_rev = @source_helper_class.save_alm_data(rev, data, id)
      new_rev.should_not eq(rev)
      delete_rev = @source_helper_class.remove_alm_data(new_rev, id)
      delete_rev.should_not eq(new_rev)
    end

    it "revision conflict" do
      rev = @source_helper_class.save_alm_data(nil, data, id)
      new_rev = @source_helper_class.save_alm_data(rev, data, id)
      new_rev.should_not eq(rev)
      @source_helper_class.save_alm_data(rev, data, id)

      ErrorMessage.count.should == 1
      error_message = ErrorMessage.first
      error_message.class_name.should eq("Net::HTTPConflict")
      error_message.message.should eq("Conflict while requesting \"#{url}\"")
    end

    it "handle missing data" do
      get_response = @source_helper_class.get_alm_data(id)
      get_response.should eq(error)
      ErrorMessage.count.should == 0
    end
  end
end
