# encoding: UTF-8

require 'spec_helper'

describe Scopus do
  let(:scopus) { FactoryGirl.create(:scopus) }

  it "should report that there are no events if the DOI is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    scopus.get_data(article).should eq({ :events => [], :event_count => nil })
  end

  context "use the Scopus API" do
    let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.000001") }

    context "use article without events" do
      it "should report if there are no events and event_count returned by the Scopus API" do
        stub = stub_request(:post, Scopus::query_url(scopus.live_mode)).with(:body => File.read(fixture_path + 'scopus_post.xml'), :headers => {'Content-Type'=>'text/xml; charset=utf-8', 'Soapaction'=>'""'}).to_return(:headers => {'Content-Type'=>'text/xml; charset=utf-8'}, :body => File.read(fixture_path + 'scopus_nil.xml'), :status => 200)
        scopus.get_data(article).should eq({:events=>0, :events_url=>"http://www.scopus.com/scopus/inward/citedby.url?doi=10.1371%2Fjournal.pone.000001&rel=R3.0.0&partnerID=EXAMPLE&md5=0ecd2f56933e4baa02bd2693440f1691", :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0}})
        stub.should have_been_requested
      end
    end

    context "use article with events" do
      # it "should report if there are events and event_count returned by the Scopus API" do
      #   stub = stub_request(:post, Scopus::query_url(scopus.live_mode)).with(:body => File.read(fixture_path + 'scopus_post.xml'), :headers => {'Content-Type'=>'text/xml; charset=utf-8', 'Soapaction'=>'""'}).to_return(:headers => {'Content-Type'=>'text/xml; charset=utf-8'}, :body => File.read(fixture_path + 'scopus.xml'), :status => 200)
      #   scopus.get_data(article).should eq({:events=>0, :events_url=>"http://www.scopus.com/scopus/inward/citedby.url?doi=10.1371%2Fjournal.pone.000001&rel=R3.0.0&partnerID=EXAMPLE&md5=0ecd2f56933e4baa02bd2693440f1691", :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>23, :total=>23}})
      #   stub.should have_been_requested
      # end

      it "should catch 404 errors with the Scopus API" do
        stub = stub_request(:post, Scopus::query_url(scopus.live_mode)).with(:body => File.read(fixture_path + 'scopus_post.xml'), :headers => {'Content-Type'=>'text/xml; charset=utf-8', 'Soapaction'=>'""'}).to_return(:status => [404])
        scopus.get_data(article, options = { :source_id => scopus.id }).should eq({:events=>0, :events_url=>"http://www.scopus.com/scopus/inward/citedby.url?doi=10.1371%2Fjournal.pone.000001&rel=R3.0.0&partnerID=EXAMPLE&md5=0ecd2f56933e4baa02bd2693440f1691", :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0}})
        stub.should have_been_requested
        Alert.count.should == 0
      end

      it "should catch 408 errors with the Scopus API" do
        stub = stub_request(:post, Scopus::query_url(scopus.live_mode)).with(:body => File.read(fixture_path + 'scopus_post.xml'), :headers => {'Content-Type'=>'text/xml; charset=utf-8', 'Soapaction'=>'""'}).to_return(:status => [408])
        scopus.get_data(article, options = { :source_id => scopus.id }).should be_nil
        stub.should have_been_requested
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("SOAP::HTTPStreamError")
        alert.message.should eq("A 408 error occured for article #{article.doi}")
        alert.status.should == 408
        alert.source_id.should == scopus.id
      end
    end
  end
end
