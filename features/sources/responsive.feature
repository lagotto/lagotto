Feature: Responsive design of sources
  In order to be useable with mobile applications
  The layout should respond to the screen size

  Background:
    Given I am logged in
    And the screen size is "480" x "640"
    And the source "CiteULike" exists
    And that we have 10 articles
    
  @javascript
  Scenario: The navigation bar should be adapted to the resolution
    When I go to the "Articles" page 
    Then I should not see the "Home" link in the menu bar
    Then I should not see the "Sign Out" link in the menu bar
    
  @javascript
  Scenario: I should not see all information for groups
    When I go to the "Sources" admin page
    Then I should not see the "Group" column
    
  @javascript
  Scenario: I should not see the source summary tab
    When I go to the source "CiteULike"
    Then I should not see the "Summary" tab