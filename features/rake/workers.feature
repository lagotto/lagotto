Feature: Start and stop workers
  I should be able to start and stop workers
  
  @slow_process @not-teamcity
  Scenario: Start all workers
    When I run `bundle exec rake workers:start_all` interactively
    Then the exit status should be 0
  
  @slow_process @not-teamcity
  Scenario: Stop all workers
    When I run `bundle exec rake workers:stop_all` interactively
    Then the exit status should be 0