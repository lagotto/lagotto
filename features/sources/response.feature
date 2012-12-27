Feature: Responses in last 24 hours
  In order see that we collect metrics correctly
  An admin user
  Should be able to see the responses from the last 24 hours

  Background:
    Given I am logged in
    And the source "CiteULike" exists
    And that we have 10 articles
    
    @javascript
    Scenario: Responses from last 24 hours
      When I go to the "Configuration" tab of source "CiteULike"
      Then I should see the "Errors" column