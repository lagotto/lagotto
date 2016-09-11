require 'rails_helper'

describe "notification:fatal_error_report" do
  include_context "rake"

  ENV['MESSAGE'] = "A test error occured."

  let(:output) { "Fatal error report sent\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end
