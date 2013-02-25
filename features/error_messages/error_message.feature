Feature: Show errors
  In order to make sure that we collect metrics correctly
  An admin user
  Should see errors

  Background:
    Given I am logged in
    And that we have 2 error messages
    
    @javascript
    Scenario: Seeing a list of errors
      When I go to the "Errors" admin page
      Then I should see 2 error messages
    
    @javascript
    Scenario Outline: Seeing error information
      When I go to the "Errors" admin page
      Then I should see the "<Message>" error message
      And I should not see the "<ClassName>" class name
      
      Examples: 
        | Message                | ClassName               | 
        | The request timed out. | Net::HTTPRequestTimeOut | 
    
    @javascript
    Scenario Outline: Seeing error details
    When I go to the "Errors" admin page
    And I click on the "[408] The request timed out." link
    Then I should see the "<Message>" error message
    And I should see the "<ClassName>" class name
      
      Examples: 
        | Message                 | ClassName               | 
        | The request timed out.  | Net::HTTPRequestTimeOut | 
    
    @javascript
    Scenario Outline: Errors
      When I go to "<Path>"
      Then I should see the "<ErrorMessage>" error message
      
      Examples: 
        | Path        | ErrorMessage          | ClassName                      |
        | /articles/x | Internal server error | ActiveRecord::RecordNotFound   |
        | /x          | Internal server error | ActionController::RoutingError |
