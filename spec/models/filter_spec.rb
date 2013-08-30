require 'spec_helper'

describe Filter do

  subject { Filter }

  it { should respond_to(:all) }
  it { should respond_to(:last_id) }
  it { should respond_to(:decreasing) }
  it { should respond_to(:increasing) }
  it { should respond_to(:slow) }
  it { should respond_to(:resolve) }
  it { should respond_to(:raise_errors) }

  context "API responses" do
    before do
      @api_responses = FactoryGirl.create_list(:api_response, 3, event_count: 1050, duration: 16000)
      @id = @api_responses.last.id
    end

    it "should get the last insert id" do
      subject.last_id.should eq(@id)
    end

    it "should call all filters" do
      response = { decreasing: 0, increasing: 3, slow: 3, resolve: 3 }
      subject.all.should eq(response)
    end
  end

  context "no API responses" do
    it "should get nil as last insert id if no API responses" do
      subject.last_id.should be_nil
    end

    it "should get 0 errors if no API responses" do
      response = { decreasing: 0, increasing: 0, slow: 0, resolve: 0 }
      subject.all.should eq(response)
    end
  end

  context "decreasing event count" do
    let(:api_responses) { FactoryGirl.create_list(:api_response, 3, previous_count: 12) }
    let(:id) { api_responses.last.id }

    it "should raise errors" do
      subject.decreasing(id).should eq(api_responses.size)
    end
  end

  context "increasing event count" do
    let(:api_responses) { FactoryGirl.create_list(:api_response, 3, event_count: 1050) }
    let(:id) { api_responses.last.id }

    it "should raise errors" do
      subject.increasing(id).should eq(api_responses.size)
    end
  end

  context "slow API responses" do
    let(:api_responses) { FactoryGirl.create_list(:api_response, 3, duration: 16000) }
    let(:id) { api_responses.last.id }

    it "should raise errors" do
      subject.slow(id).should eq(api_responses.size)
    end
  end

  context "resolve" do
    let(:api_responses) { FactoryGirl.create_list(:api_response, 3) }
    let(:id) { api_responses.last.id }

    it "should resolve API responses" do
      subject.resolve(id).should eq(api_responses.size)
    end
  end
end
