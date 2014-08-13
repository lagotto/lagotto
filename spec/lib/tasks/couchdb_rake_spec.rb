require 'spec_helper'

describe "couchdb:histories:delete" do
  include_context "rake"

  let(:output) { "No CouchDB history documents to delete.\n" }

  its(:prerequisites) { should include("environment") }

  it "should run the rake task" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end
