require "rails_helper"
require "models/reports/source_report_shared_examples"

describe "Running a SourceReport for Pmc" do
  include_examples "SourceReport examples", source_factory: :pmc
end
