Feature: Run rake tasks
  I should be able to run rake tasks

  Scenario: rake is installed
    When I run `rake --version`
    Then the output should contain "rake, version"
    
  Scenario Outline: rake tasks exist
    When I run `rake -T`
    Then the output should contain "<Task>"
    And the output should contain "<Description>"
    
    Examples: 
      | Task                         | Description                                        |
      | doi_import                   | Bulk-import DOIs from standard input               |
      | jobs:work                    | Start a delayed_job worker.                        |
      | workers:start_all            | Start all the workers                              |
      | queue:single_job[doi,source] | Queue article with given DOI for a specific source |