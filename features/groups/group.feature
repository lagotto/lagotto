@javascript
Feature: Edit groups
  In order to organize sources
  A user
  Should be able to add, edit or delete a group

    Background:
      Given I am logged in as "admin"
      And I have a group "Saved"

    Scenario: Group is added succesfully
      When I add the group "Cited"
      Then I should see the group "Cited"

    Scenario: Group is changed succesfully
      When I change the name of group "Saved" to "Cited"
      Then I should see the group "Cited"

    Scenario: Name for group missing
      When I change the name of group "Saved" to ""
      Then I should see the error "can't be blank"

    Scenario: Group exists already
      When I add the group "Cited"
      And I change the name of group "Cited" to "Saved"
      Then I should see the error "has already been taken"

    Scenario: Group is deleted succesfully
      When I delete the group "Saved"
      Then I should not see the group "Saved"
