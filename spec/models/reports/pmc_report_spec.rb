require "rails_helper"

describe "Running a PmcReport for Pmc" do
  include_examples "SourceReport examples",
    source_factory: :pmc,
    report_class: PmcReport
end
