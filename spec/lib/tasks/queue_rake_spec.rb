require 'rails_helper'

describe "queue:all[plos_import]", vcr: true do
  include_context "rake"

  ENV['FROM_DATE'] = "2013-09-04"
  ENV['UNTIL_DATE'] = "2013-09-05"

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

describe "queue:all[crossref_import]", vcr: true do
  include_context "rake"

  ENV['FROM_DATE'] = "2013-09-04"
  ENV['UNTIL_DATE'] = "2013-09-05"

  before do
    FactoryGirl.create(:crossref_import)
  end

  let(:output) { "Queueing all works published from 2013-09-04 to 2013-09-05.\n43695 works for agent Crossref Import have been queued.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "queue:all[datacite_import]", vcr: true do
  include_context "rake"

  ENV['FROM_DATE'] = "2013-09-04"
  ENV['UNTIL_DATE'] = "2013-09-05"

  before do
    FactoryGirl.create(:datacite_import)
  end

  let(:output) { "Queueing all works published from 2013-09-04 to 2013-09-05.\n414 works for agent Datacite (Import) have been queued.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "queue:all[dataone_import]", vcr: true do
  include_context "rake"

  ENV['FROM_DATE'] = "2013-09-04"
  ENV['UNTIL_DATE'] = "2013-09-05"

  before do
    FactoryGirl.create(:dataone_import)
  end

  let(:output) { "Queueing all works published from 2013-09-04 to 2013-09-05.\n52 works for agent DataONE Import have been queued.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end
