require "rails_helper"

describe "Running a SourceByMonthReport for Counter" do
  include_examples "SourceByMonthReport examples", source_factory: :counter
end
