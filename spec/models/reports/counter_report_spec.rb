require "rails_helper"

describe "Running a SourceReport for Counter" do
  include_examples "SourceReport examples", source_factory: :counter
end
