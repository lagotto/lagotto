require 'rails_helper'

describe Agent do

  context "CouchDB" do
    before(:each) do
      put_lagotto_data("http://localhost:5984/test")
    end

    after(:each) do
      delete_lagotto_data("http://localhost:5984/test")
    end

    let(:url) { "http://localhost:5984/test/4" }
    let(:data) { { "name" => "Fred"} }
    let(:error) { {"error"=>"not_found", "reason"=>"missing"} }

    it "put, get and delete data" do
      rev = subject.put_lagotto_data(url, data: data)
      expect(rev).not_to be_nil

      get_response = subject.get_lagotto_data(url)
      expect(get_response).to include("_rev" => rev)

      new_rev = subject.save_lagotto_data(url, data: data)
      expect(new_rev).not_to be_nil
      expect(new_rev).not_to eq(rev)

      delete_rev = subject.remove_lagotto_data(url)
      expect(delete_rev).not_to be_nil
      expect(delete_rev).not_to eq(rev)
      expect(delete_rev).to include("3-")
    end

    it "get correct revision" do
      rev = subject.put_lagotto_data(url, data: data)
      expect(rev).not_to be_nil

      new_rev = subject.get_lagotto_rev(url)
      expect(new_rev).not_to be_nil
      expect(new_rev).to eq(rev)
    end

    it "get nil for missing url" do
      rev = subject.get_lagotto_rev("xxx")
      expect(rev).to be_blank
    end

    it "handle revisions" do
      rev = subject.save_lagotto_data(url, data: data)
      new_rev = subject.save_lagotto_data(url, data: data)
      expect(new_rev).not_to be_nil
      expect(new_rev).not_to eq(rev)
      delete_rev = subject.remove_lagotto_data(url)
      expect(delete_rev).not_to eq(new_rev)
    end

    it "revision conflict" do
      rev = subject.put_lagotto_data(url, data: data)
      new_rev = subject.put_lagotto_data(url, data: data)
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPConflict")
      expect(notification.status).to eq(409)
    end

    it "handle missing data" do
      get_response = subject.get_lagotto_data(url)
      expect(get_response).to eq(error: "not_found", status: 404)
      expect(Notification.count).to eq(0)
    end
  end
end
