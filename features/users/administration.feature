@javascript
Feature: Manage users
  In order to manage ALM
  Admin users should be able to manage user accounts

  Background:
    Given I am logged in as "admin"

    Scenario: See list of users
      When we have 5 users
      And I go to the "Users" admin page
      Then I should see 5 users

    Scenario: See user details
      Given we have user "joeboxer" with name "Joe Boxer"
      When I go to the "Users" admin page
      And I click on user "joeboxer"
      Then I should see the "User" role for user "joeboxer"

    Scenario: Delete user
      Given we have user "joeboxer" with name "Joe Boxer"
      When I go to the "Users" admin page
      And I click on user "joeboxer"
      And I click on the Delete button for user "joeboxer" and confirm
      Then I should not see user "joeboxer"

    Scenario: Change user role
      Given we have user "joeboxer" with name "Joe Boxer"
      When I go to the "Users" admin page
      And I click on user "joeboxer"
      And I click on the "Role Staff" submenu of button Edit for user "joeboxer"
      And I click on user "joeboxer"
      Then I should see the "Staff" role for user "joeboxer"