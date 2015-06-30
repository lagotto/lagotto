require "rails_helper"

describe "Running a SourceByMonthReport for Pmc" do
  include_examples "SourceByMonthReport examples",
    source_factory: :pmc,
    report_class: SourceByMonthReport
end
