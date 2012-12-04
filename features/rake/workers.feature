Feature: Start and stop workers
  I should be able to start and stop workers
  
  Scenario: Start all workers
    When I run `bundle exec rake workers:start_all` interactively
    Then the exit status should be 0
    
  Scenario: Stop all workers
    When I run `bundle exec rake workers:stop_all` interactively
    Then the exit status should be 0