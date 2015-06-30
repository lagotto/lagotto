require "rails_helper"

describe "Running a PmcByMonthReport for Pmc" do
  include_examples "SourceByMonthReport examples",
    source_factory: :pmc,
    report_class: PmcByMonthReport
end
