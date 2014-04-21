Feature: Run rake tasks
  I should be able to run rake tasks

  Scenario: rake is installed
    When I run `bundle exec rake --version` interactively
    Then the output should contain "rake, version"
  @not_teamcity
  Scenario Outline: rake tasks exist
    When I run `bundle exec rake -T` interactively
    Then the output should contain "<Task>"
    And the output should contain "<Description>"

    Examples:
      | Task                             | Description                                                     |
      | jobs:work                        | Start a delayed_job worker                                      |
      | workers:start                    | Start all the workers                                           |
      | workers:stop                     | Stop all the workers                                            |
      | workers:monitor                  | Monitor workers                                                 |
      | queue:all                        | Queue all articles                                              |
      | queue:one[doi]                   | Queue article with given DOI                                    |
      | queue:stale                      | Queue stale articles                                            |
      | db:alerts:delete                 | Delete all resolved alerts                                      |
      | db:api_requests:delete           | Delete API requests, keeping last 10,000 requests                |
      | db:articles:seed                 | Seed sample articles                                            |
      | db:articles:load                 | Bulk-load articles from standard input                          |
      | db:articles:delete               | Delete all articles                                             |
      | filter:all                       | Create alerts by filtering API responses                        |
      | mailer:all                       | Send all scheduled mails                                        |
      | mailer:article_statistics_report | Send article statistics report                                  |
      | mailer:error_report              | Send error report                                               |
      | mailer:status_report             | Send status report                                              |
      | pmc:update                       | Bulk-import PMC usage stats by month and journal                |
      | report:all_stats                 | Generate all article stats reports                              |
      | report:alm_private_stats         | Generate CSV file with ALM stats for private and public sources |
      | report:alm_stats                 | Generate CSV file with ALM stats for public sources             |
      | report:combined_private_stats    | Generate CSV file with combined ALM private and public stats    |
      | report:combined_stats            | Generate CSV file with combined ALM stats                       |
      | report:mendeley_stats            | Generate CSV file with Mendeley stats                           |
      | report:pmc                       | Generate CSV file with PMC usage stats                          |
      | report:pmc_combined_stats        | Generate CSV file with PMC combined usage stats over time       |
      | report:pmc_html_stats            | Generate CSV file with PMC HTML usage stats over time           |
      | report:pmc_pdf_stats             | Generate CSV file with PMC PDF usage stats over time            |
      | report:pmc_stats                 | Generate CSV file with PMC cumulative usage stats               |
      | report:zip                       | Zip reports                                                     |
