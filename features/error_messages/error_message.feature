Feature: Show errors
  In order to make sure that we collect metrics correctly
  An admin user
  Should see errors

  Background:
    Given I am logged in
    And the source "CiteULike" exists
    And that we have 5 articles
    
    @javascript
    Scenario Outline: Routing errors
      When I go to "<Path>"
      Then I should see the "<ErrorMessage>" error message
      #And I should see the "<ErrorNumber>" error number
      
      Examples: 
        | Path        | ErrorNumber | ErrorMessage |
        | /sources/x  | 404         | Page not found |
        | /xx         | 500         | Internal server error |
