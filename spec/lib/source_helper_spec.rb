require 'spec_helper'
require 'source_helper'

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
        @source_helper_class.get_xml(url) { |response| Hash.from_xml(response.to_s)["hash"].should eq(data) }
      end
    end
    
    context "empty response" do
      it "get_json" do
        stub = stub_request(:get, url).to_return(:body => nil, :content_type => 'application/json', :status => 200)
        response = @source_helper_class.get_json(url)
        response.should be_empty 
      end
      
      it "get_xml" do
        stub = stub_request(:get, url).to_return(:body => nil, :content_type => 'application/xml', :status => 200)
        response = @source_helper_class.get_xml(url)
        response.should be_empty      
      end
    end
    
    context "not found" do
      let(:error) { { "error" => "no found"} }
      
      it "get_json" do
        stub = stub_request(:get, url).to_return(:body => error.to_json, :content_type => 'application/json', :status => 404)
        lambda { @source_helper_class.get_json(url) }.should raise_error(Net::HTTPServerException, /404/)
      end
      
      it "get_xml" do
        stub = stub_request(:get, url).to_return(:body => error.to_xml, :content_type => 'application/xml', :status => 404)
        lambda { @source_helper_class.get_xml(url) }.should raise_error(Net::HTTPServerException, /404/)   
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
    
    it "put, get and delete data" do
      put_response = @source_helper_class.put_alm_data(url, data.to_json)
      put_response.should be_a_kind_of(Net::HTTPCreated)
      put_body = ActiveSupport::JSON.decode(put_response.body)
      rev = put_body["rev"]
      put_body.should include("ok" => true, "id" => id)
      
      get_response = @source_helper_class.get_alm_data(id)
      get_response.should include("_id" => id, "_rev" => rev)
      
      new_rev = @source_helper_class.save_alm_data(rev, data, id)
      new_rev.should_not eq(rev)
      
      delete_response = @source_helper_class.remove_alm_data(new_rev, id)
      delete_response.should include("3-")
    end
  end
end