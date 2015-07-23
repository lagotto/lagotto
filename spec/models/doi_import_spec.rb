require 'rails_helper'

describe DoiImport, type: :model, vcr: true do

  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  context "get_data" do
    it "should get_data file" do
      filepath = fixture_path + 'doi_import.txt'
      import = DoiImport.new(filepath: filepath)
      response = import.get_data
      expect(response["items"].length).to eq(100)

      item = response["items"].first
      expect(item["doi"]).to eq("10.1016/j.rcae.2013.04.001")
    end
  end

  context "parse_data" do
    it "should parse_data default" do
      import = DoiImport.new
      body = File.read(fixture_path + 'doi_import.json')
      result = JSON.parse(body)
      response = import.parse_data(result)
      expect(response.length).to eq(100)

      work = response.first
      expect(work[:doi]).to eq("10.1016/j.rcae.2013.04.001")
      expect(work[:title]).to eq("Scientific writing, a neglected aspect of professional training")
      expect(work[:year]).to eq(2013)
      expect(work[:month]).to eq(4)
      expect(work[:day]).to be_nil
      expect(work[:publisher_id]).to eq(78)
    end
  end

  context "import_data" do
    it "should import_data" do
      import = DoiImport.new
      body = File.read(fixture_path + 'doi_import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.compact.length).to eq(100)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with one existing work" do
      work = FactoryGirl.create(:work, :doi => "10.1016/j.rcae.2013.04.001")
      import = DoiImport.new
      body = File.read(fixture_path + 'doi_import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.compact.length).to eq(100)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with missing title" do
      import = DoiImport.new
      body = File.read(fixture_path + 'doi_import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      items[0][:title] = nil
      response = import.import_data(items)
      expect(response.compact.length).to eq(99)
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("ActiveRecord::RecordInvalid")
      expect(alert.message).to eq("Validation failed: Title can't be blank for doi 10.1016/j.rcae.2013.04.001.")
      expect(alert.target_url).to eq("http://doi.org/10.1016/j.rcae.2013.04.001")
    end
  end
end
