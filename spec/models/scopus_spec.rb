# require 'spec_helper'
# 
# describe Scopus do
#   let(:scopus) { FactoryGirl.create(:scopus) }
#   
#   it "should report that there are no events if the doi is missing" do
#     article_without_doi = FactoryGirl.build(:article, :doi => "")
#     scopus.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
#   end
# end