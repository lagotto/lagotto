require 'rails_helper'

describe FileImport, type: :model, vcr: true do

  before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  context "get_data" do
    it "should get_data file" do
      input = File.readlines(fixture_path + 'works.txt')
      import = FileImport.new(file: input)
      response = import.get_data
      expect(response["items"].length).to eq(2)

      item = response["items"].first
      expect(item["doi"]).to eq("10.1371/journal.pone.0040259")
      expect(item["issued"]["date-parts"]).to eq([[2012, 7, 11]])
      expect(item["title"]).to eq(["The Eyes Don’t Have It: Lie Detection and Neuro-Linguistic Programming"])
    end

    it "should get_data file missing day" do
      input = File.readlines(fixture_path + 'works_year_month.txt')
      import = FileImport.new(file: input)
      response = import.get_data
      expect(response["items"].length).to eq(2)

      item = response["items"].first
      expect(item["doi"]).to eq("10.1371/journal.pone.0040259")
      expect(item["issued"]["date-parts"]).to eq([[2012, 8]])
      expect(item["title"]).to eq(["The Eyes Don’t Have It: Lie Detection and Neuro-Linguistic Programming"])
    end

    it "should get_data file missing month and day" do
      input = File.readlines(fixture_path + 'works_year.txt')
      import = FileImport.new(file: input)
      response = import.get_data
      expect(response["items"].length).to eq(2)

      item = response["items"].first
      expect(item["doi"]).to eq("10.1371/journal.pone.0040259")
      expect(item["issued"]["date-parts"]).to eq([[2011]])
      expect(item["title"]).to eq(["The Eyes Don’t Have It: Lie Detection and Neuro-Linguistic Programming"])
    end

    it "should get_data file missing dates" do
      input = File.readlines(fixture_path + 'works_nil_dates.txt')
      import = FileImport.new(file: input)
      response = import.get_data
      expect(response["items"].length).to eq(1)

      item = response["items"].first
      expect(item["doi"]).to eq("10.1371/journal.pone.0040259")
      expect(item["issued"]["date-parts"]).to eq([[]])
      expect(item["title"]).to eq(["Eyes Don’t Have It: Lie Detection and Neuro-Linguistic Programming"])
    end

    it "should get_data file non-utf-8 characters" do
      input = []
      File.readlines(fixture_path + 'works_not_utf8.txt').each { |line| input << ActiveSupport::Multibyte::Unicode.tidy_bytes(line) }
      import = FileImport.new(file: input)
      response = import.get_data
      expect(response["items"].length).to eq(5)

      item = response["items"].first
      expect(item["doi"]).to eq("10.1371/journal.pone.0103093")
      expect(item["issued"]["date-parts"]).to eq([[2014, 7, 29]])
      expect(item["title"]).to eq(["Capsaicin Induces “Brite” Phenotype in Differentiating 3T3-L1 Preadipocytes"])
    end
  end
end
