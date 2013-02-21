Feature: Show API requests
  In order to make sure that we collect metrics correctly
  An admin user
  Should see the number and average duration of API requests

  # Background:
  #   Given I am logged in
  #   And that we have 3 API requests
  #   
  #   @javascript
  #   Scenario: Seeing request information
  #     When I go to the "API" admin page
  #     Then the table "ApiRequestsTable" should contain:
  #       | Requests in the last 24 Hours         | 3  | 100.0                   | 700.0                 |
  #       | Requests in the last 30 Days          | 3  | 100.0                   | 700.0                 |
  #       
  #   @javascript
  #   Scenario: Making an API request
  #     When I make 2 API requests
  #     And I go to the "API" admin page
  #     Then the table "ApiRequestsTable" should contain:
  #       | Requests in the last 24 Hours         | 5  |
  #       | Requests in the last 30 Days          | 5  | 
      
