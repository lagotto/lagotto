require 'rails_helper'

describe "couchdb:histories:delete" do
  include_context "rake"

  let(:output) { "No CouchDB history documents to delete.\n" }

  it "prerequisites should include environment" do
    subject.prerequisites.should include("environment")
  end

  it "should run the rake task" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end
