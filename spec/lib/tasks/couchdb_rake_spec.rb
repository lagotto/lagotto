require 'rails_helper'

describe "couchdb:histories:delete" do
  include_context "rake"

  let(:output) { "No CouchDB history documents to delete.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end
