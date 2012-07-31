Feature: Delete group
  In order to organize sources
  A user
  Should be able to delete a group
  
    Background:
      Given I am logged in
  
    Scenario: Group is deleted succesfully
      Given I have a group named Citations
      When I delete the group
      Then I should not see the group Citations
