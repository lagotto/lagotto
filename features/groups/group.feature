Feature: Edit group
  In order to organize sources
  A user
  Should be able to edit a group
  
    Background:
      Given I am logged in
  
    Scenario: Group is changed succesfully
      Given I have a group named Citations
      When I edit the group with all required information
      Then I should not see the group Citations
    
    Scenario: Name for group missing
      Given I have a group named Citations
      When I edit the group without giving a name
      Then I should see an error
    
    Scenario: Group exists already
      Given I have a group named Citations
      When I change the group name to Statistics
      Then I should see an error