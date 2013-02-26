Feature: Import PMC data
  I should be able to import PMC data
  
  Scenario: Import PMC data
    When I run `bundle exec rake pmc:update[1,2013]` interactively
    Then the output should contain "Getting PMC information for 1 2013"
    And the exit status should be 0