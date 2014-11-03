@javascript
Feature: Select Reports
  In order to monitor ALM
  Staff users should be able to select reports

  Background:
    Given I am logged in as "staff"

    Scenario: Staff can see report
      Given we have report "Error Report"
      And we have selected the report
      When I go to my account page
      Then I should see the report "Error Report"

    Scenario: Staff can select report
      Given we have report "Error Report"
      When I go to my account page
      And I click on the "Subscribe" link
      Then I should see the "Unsubscribe" link

    Scenario: Staff can unselect report
      Given we have report "Error Report"
      And we have selected the report
      When I go to my account page
      And I click on the "Unsubscribe" link
      Then I should see the "Subscribe" link
