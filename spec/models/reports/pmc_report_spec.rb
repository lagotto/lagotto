require "rails_helper"

describe "Running a SourceReport for Pmc" do
  include_examples "SourceReport examples", source_factory: :pmc
end
