require 'rails_helper'

describe SciencetoolboxImport, :type => :model do

  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  context "total_results" do
    it "should have total_results" do
      filepath = fixture_path + "sciencetoolbox_import.json"
      import = SciencetoolboxImport.new(filepath: filepath)
      expect(import.total_results).to eq(10)
    end
  end

  context "get_data" do
    it "should get_data file" do
      filepath = fixture_path + "sciencetoolbox_import.json"
      import = SciencetoolboxImport.new(filepath: filepath)
      response = import.get_data
      expect(response.length).to eq(10)

      item = response.first
      expect(item["url"]).to eq("https://github.com/astropy/astropy")
      expect(item["metadata"]["updated_at"]).to eq("2014-02-13 00:59:53 UTC")
      expect(item["description"]).to eq("Main Astropy repository")
    end
  end

  context "parse_data" do
    it "should parse_data default" do
      import = SciencetoolboxImport.new
      body = File.read(fixture_path + "sciencetoolbox_import.json")
      result = JSON.parse(body)
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response.first
      expect(work[:canonical_url]).to eq("https://github.com/astropy/astropy")
      expect(work[:title]).to eq("Main Astropy repository")
      expect(work[:year]).to eq(2014)
    end

    it "should parse_data missing date" do
      import = SciencetoolboxImport.new
      body = File.read(fixture_path + "sciencetoolbox_import.json")
      result = JSON.parse(body)
      result[5]["metadata"]["updated_at"] = nil
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response[5]
      expect(work[:canonical_url]).to eq("https://github.com/realXtend/doc")
      expect(work[:title]).to eq("Auxiliary documentation for the realXtend architecture")
      expect(work[:year]).to eq(nil)
    end

    it "should parse_data missing title" do
      import = SciencetoolboxImport.new
      body = File.read(fixture_path + "sciencetoolbox_import.json")
      result = JSON.parse(body)
      result[5]["description"] = nil
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response[5]
      expect(work[:canonical_url]).to eq("https://github.com/realXtend/doc")
      expect(work[:title]).to be_nil
    end
  end
end
