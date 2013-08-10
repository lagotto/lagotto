@javascript
Feature: Show errors
  In order to make sure that we collect metrics correctly
  An admin user
  Should see errors

  Background:
    Given I am logged in as "admin"
    And we have 1 error message
    
    Scenario: Seeing a list of errors
      When I go to the "Errors" admin page
      Then I should see 1 error message
    
    Scenario Outline: Seeing error information
      When I go to the "Errors" admin page
      Then I should see the "<Message>" error message
      And I should not see the "<ClassName>" class name
      
      Examples: 
        | Message                | ClassName               | 
        | The request timed out. | Net::HTTPRequestTimeOut | 
    
    Scenario Outline: Seeing error details
      When I go to the "Errors" admin page
      And I click on the "[408] The request timed out." link
      Then I should see the "<Message>" error message
      And I should see the "<ClassName>" class name
      
      Examples: 
        | Message                 | ClassName               | 
        | The request timed out.  | Net::HTTPRequestTimeOut | 
        
    @allow-rescue
    Scenario Outline: Errors
      When I go to "<Path>"
      Then I should see the "<ErrorMessage>" error message
      
      Examples: 
        | Path        | ErrorMessage                |
        | /articles/x | No record for "x" found     |
        | /x          | No route matches [GET] "/x" |
