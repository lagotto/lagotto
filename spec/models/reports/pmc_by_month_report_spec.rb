require "rails_helper"

describe "Running a PmcByMonthReport for Pmc" do
  include_examples "SourceByMonthReport examples",
    source_factory: :pmc_html,
    report_class: PmcByMonthReport
end
