Feature: Start and stop workers
  I should be able to start and stop workers

  Scenario: Start all workers
    When I run `bundle exec rake workers:start` interactively
    Then the exit status should be 0

  Scenario: Stop all workers
    When I run `bundle exec rake workers:stop` interactively
    Then the exit status should be 0

 # Scenario: Stop all workers
 #   Given we have report "missing_workers_report"
 #   When I run `bundle exec rake workers:monitor` interactively
 #   Then the exit status should be 0
