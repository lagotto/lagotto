require 'rails_helper'

describe "queue:all[plos_import]", vcr: true do
  include_context "rake"

  ENV['FROM_PUB_DATE'] = "2013-09-04"
  ENV['UNTIL_PUB_DATE'] = "2013-09-05"

  before do
    FactoryGirl.create(:plos_import)
  end

  let(:output) { "Queueing all works published from 2013-09-04 to 2013-09-05.\n394 works for agent PLOS Import have been queued.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "queue:all[dataone_import]", vcr: true do
  include_context "rake"

  ENV['FROM_PUB_DATE'] = "2013-09-04"
  ENV['UNTIL_PUB_DATE'] = "2013-09-05"

  before do
    FactoryGirl.create(:plos_import)
  end

  let(:output) { "Queueing all works published from 2013-09-04 to 2013-09-05.\n394 works for agent DataONE Import have been queued.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end
