require 'rails_helper'

describe Source do

  context "CouchDB" do
    before(:each) do
      subject.put_lagotto_database
    end

    after(:each) do
      subject.delete_lagotto_database
    end

    let(:id) { "test" }
    let(:url) { "#{ENV['COUCHDB_URL']}/#{id}" }
    let(:data) { { "name" => "Fred"} }
    let(:error) { {"error"=>"not_found", "reason"=>"missing"} }

    it "put filter views" do
      # data = subject.get_lagotto_data("_design/filter/_view/html_ratio")
    end

    it "get database info" do
      rev = subject.put_lagotto_data(url, data: data)

      get_info = subject.get_lagotto_database
      db_name = Addressable::URI.parse(ENV['COUCHDB_URL']).path[1..-1]
      expect(get_info["db_name"]).to eq(db_name)
      expect(get_info["disk_size"]).to be > 0
      expect(get_info["doc_count"]).to be > 0
    end

    it "put, get and delete data" do
      rev = subject.put_lagotto_data(url, data: data)
      expect(rev).not_to be_nil

      get_response = subject.get_lagotto_data(id)
      expect(get_response).to include("_id" => id, "_rev" => rev)

      new_rev = subject.save_lagotto_data(id, data: data)
      expect(new_rev).not_to be_nil
      expect(new_rev).not_to eq(rev)

      delete_rev = subject.remove_lagotto_data(id)
      expect(delete_rev).not_to be_nil
      expect(delete_rev).not_to eq(rev)
      expect(delete_rev).to include("3-")
    end

    it "get correct revision" do
      rev = subject.put_lagotto_data(url, data: data)
      expect(rev).not_to be_nil

      new_rev = subject.get_lagotto_rev(id)
      expect(new_rev).not_to be_nil
      expect(new_rev).to eq(rev)
    end

    it "get nil for missing id" do
      rev = subject.get_lagotto_rev("xxx")
      expect(rev).to be_blank
    end

    it "handle revisions" do
      rev = subject.save_lagotto_data(id, data: data)
      new_rev = subject.save_lagotto_data(id, data: data)
      expect(new_rev).not_to be_nil
      expect(new_rev).not_to eq(rev)
      delete_rev = subject.remove_lagotto_data(id)
      expect(delete_rev).not_to eq(new_rev)
    end

    it "revision conflict" do
      rev = subject.put_lagotto_data(url, data: data)
      new_rev = subject.put_lagotto_data(url, data: data)
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPConflict")
      expect(alert.status).to eq(409)
    end

    it "handle missing data" do
      get_response = subject.get_lagotto_data(id)
      expect(get_response).to eq(error: "not_found", status: 404)
      expect(Alert.count).to eq(0)
      alert = Alert.first

      expect(alert.message).to eq("the server responded with status 400 for http://localhost:5984/lagotto/_design/reports")
    end
  end
end
