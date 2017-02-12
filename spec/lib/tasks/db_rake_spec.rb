require 'rails_helper'

describe "db:works:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:work, 5)
  end

  let(:output) { "Started deleting all works in the background...\n" }

  it "should run" do
    ENV['PUBLISHER_ID'] = "all"
    ENV['SOURCE_ID'] = "all"
    expect(capture_stdout { subject.invoke }).to eq(output)
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
