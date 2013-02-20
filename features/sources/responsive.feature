Feature: Responsive design of sources
  In order to be useable with mobile applications
  The layout should respond to the screen size

  Background:
    Given I am logged in
    And the screen size is "480" x "640"
    And the source "Citeulike" exists
    And that we have 10 articles
    
  @javascript
  Scenario: I should  see all information for groups
    When I go to the "Sources" admin page
    Then I should see the "Group" column
    
  @javascript
  Scenario: I should see the source summary tab
    When I go to the source "CiteULike"
    Then I should see the "Summary" tab
    And I should not see the "Configuration" tab