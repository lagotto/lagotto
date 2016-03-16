require 'rails_helper'

describe "db:works:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:work, 5)
  end

  let(:output) { "Started deleting all works in the background...\n" }

  it "should run" do
    ENV['MEMBER'] = "all"
    expect(capture_stdout { subject.invoke }).to eq(output)
    ENV['MEMBER'] = nil
  end
end

describe "db:works:sanitize_title" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:work, 5)
  end

  let(:output) { "5 work titles sanitized\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:notifications:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:notification, 5, :unresolved => false)
  end

  let(:output) { "Deleted 5 resolved notifications, 0 unresolved notifications remaining\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:api_requests:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:api_request, 5)
  end

  let(:output) { "Deleted 0 API requests\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:api_responses:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:api_response, 5, created_at: Time.zone.now - 2.days)
  end

  let(:output) { "Deleted 5 API responses\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:agents:activate" do
  include_context "rake"

  before do
    FactoryGirl.create(:agent, state_event: 'install')
  end

  let(:output) { "Agent CiteULike has been activated and is now waiting.\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:agents:inactivate" do
  include_context "rake"

  before do
    FactoryGirl.create(:agent)
  end

  let(:output) { "Agent CiteULike has been inactivated.\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:agents:install" do
  include_context "rake"

  before do
    FactoryGirl.create(:agent, state_event: nil)
  end

  let(:output) { "Agent CiteULike has been installed.\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:agents:uninstall[citeulike,pmc]" do
  include_context "rake"

  before do
    FactoryGirl.create(:agent)
    FactoryGirl.create(:pmc)
  end

  let(:output) { "Agent CiteULike has been uninstalled.\nAgent PubMed Central Usage Stats has been uninstalled.\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke(*task_args) }).to eq(output)
  end
end
