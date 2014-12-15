require 'rails_helper'

describe CslImport, :type => :model do

  before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  context "total_results" do
    it "should have total_results" do
      json = File.read(fixture_path + 'csl_import.json')
      input = JSON.parse(json)
      import = CslImport.new(file: input)
      expect(import.total_results).to eq(10)
    end
  end

  context "get_data" do
    it "should get_data file" do
      json = File.read(fixture_path + 'csl_import.json')
      input = JSON.parse(json)
      import = CslImport.new(file: input)
      response = import.get_data
      expect(response.length).to eq(10)

      item = response.first
      expect(item["DOI"]).to eq("10.1056/NEJMoa0904554")
      expect(item["issued"]["date-parts"]).to eq([[2009, 9, 3]])
      expect(item["title"]).to eq("Screening for Epidermal Growth FactorReceptor Mutations in Lung Cancer")
    end

    it "should get_data file missing day" do
      json = File.read(fixture_path + 'csl_import.json')
      input = JSON.parse(json)
      import = CslImport.new(file: input)
      response = import.get_data
      expect(response.length).to eq(10)

      item = response[4]
      expect(item["DOI"]).to eq("10.1016/0959-8049(93)90617-O")
      expect(item["issued"]["date-parts"]).to eq([["1993", 1]])
      expect(item["title"]).to eq("Interleukin-2 in combination with interferon-α and 5-fluorouracil for metastatic renal cell cancer")
    end

    it "should get_data file missing month and day" do
      json = File.read(fixture_path + 'csl_import.json')
      input = JSON.parse(json)
      import = CslImport.new(file: input)
      response = import.get_data
      expect(response.length).to eq(10)

      item = response[2]
      expect(item["DOI"]).to eq("10.1242/dmm.007245")
      expect(item["issued"]["date-parts"]).to eq([["2011"]])
      expect(item["title"]).to eq("The contribution of mouse models to understanding the pathogenesis of spinal muscular atrophy")
    end
  end

  context "parse_data" do
    it "should parse_data default" do
      import = CslImport.new
      body = File.read(fixture_path + "csl_import.json")
      result = JSON.parse(body)
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response.first
      expect(work[:doi]).to eq("10.1056/NEJMoa0904554")
      expect(work[:title]).to eq("Screening for Epidermal Growth FactorReceptor Mutations in Lung Cancer")
      expect(work[:year]).to eq(2009)
      expect(work[:publisher_id]).to be_nil
    end

    it "should parse_data incomplete date" do
      import = CslImport.new
      body = File.read(fixture_path + "csl_import.json")
      result = JSON.parse(body)
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response[2]
      expect(work[:doi]).to eq("10.1242/dmm.007245")
      expect(work[:title]).to eq("The contribution of mouse models to understanding the pathogenesis of spinal muscular atrophy")
      expect(work[:year]).to eq(2011)
      expect(work[:publisher_id]).to be_nil
    end

    it "should parse_data missing title" do
      import = CslImport.new
      body = File.read(fixture_path + "csl_import.json")
      result = JSON.parse(body)
      result[5]["title"] = nil
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response[5]
      expect(work[:doi]).to eq("10.1186/1471-2148-6-50")
      expect(work[:title]).to be_nil
    end
  end
end
