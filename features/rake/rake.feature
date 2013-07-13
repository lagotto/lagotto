Feature: Run rake tasks
  I should be able to run rake tasks

  Scenario: rake is installed
    When I run `bundle exec rake --version`
    Then the output should contain "rake, version"
    
  Scenario Outline: rake tasks exist
    When I run `bundle exec rake -T`
    Then the output should contain "<Task>"
    And the output should contain "<Description>"
    
    Examples: 
      | Task                         | Description                                        |
      | jobs:work                    | Start a delayed_job worker.                        |
      | workers:start_all            | Start all the workers                              |
      | queue:single_job[doi,source] | Queue article with given DOI for a specific source |
      | db:error_messages:delete     | Delete messages for all resolved errors            |
      | db:api_requests:delete       | Delete API requests, keeping last 10,000 requests  |
      | db:articles:seed             | Seed sample articles                               |
      | db:articles:load             | Bulk-load articles from standard input             |
      | db:articles:delete           | Delete all articles                                |