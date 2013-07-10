require 'spec_helper'

describe F1000 do
  let(:f1000) { FactoryGirl.create(:f1000) }
  
  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    f1000.get_data(article).should eq({ :events => [], :event_count => nil })
  end
    
  context "use the F1000 feed" do
    before(:each) do
      filename = "#{Rails.root}/data/#{f1000.filename}"
      FileUtils.copy (fixture_path + 'f1000.xml'), filename unless File.exist?(filename)
    end
    
    it "should report if there are no events and event_count returned by the F1000 feed" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007")
      f1000.get_data(article).should eq({ :events => [], :event_count => 0 })
    end
  
    it "should report if there are events and event_count returned by the F1000 feed" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pgen.0020051")
      response = f1000.get_data(article)
      response[:event_count].should eq(2)
      response[:events_url].should eq("http://f1000.com/prime/13421")
      response[:events]["Classifications"].should eq("NEW_FINDING")
      response[:attachment][:data].should be_true
    end
   
    it "should catch an error when the F1000 feed is missing" do
      filename = "#{Rails.root}/data/#{f1000.filename}"
      File.delete filename

      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007")
      f1000.get_data(article).should be_nil
      ErrorMessage.count.should == 1
      error_message = ErrorMessage.first
      error_message.class_name.should eq("Errno::ENOENT")
      error_message.message.should include("File #{f1000.filename} not found")
      error_message.status.should == 404
      error_message.source_id.should == f1000.id
    end
  end
end