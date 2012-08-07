Feature: Add group
  In order to organize sources
  A user
  Should be able to add a group
  
    Background:
      Given I am logged in
  
    Scenario: Group is added succesfully
      Given a group does not exist
      When I add the group with all required information
      Then I should see the group
    
    Scenario: Name for group missing
      Given a group does not exist
      When I add the group without a name
      Then I should see an error
    
    Scenario: Group exists already
      Given I have a group named Citations
      When I try to add the group with all required information
      Then I should see an error