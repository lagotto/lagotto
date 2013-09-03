@javascript
Feature: Select Reports
  In order to monitor ALM
  Staff users should be able to select reports

  Background:
    Given I am logged in as "staff"

    Scenario: Staff can see report
      Given we have report "Daily Error Report"
      And we have selected the report
      When I go to my account page
      Then I should see the report "Daily Error Report"

    Scenario: Staff can select report
      Given we have report "Daily Error Report"
      When I go to my account page
      And I click on the "Edit" link
      And I check the checkbox for the report "Daily Error Report"
      And I click on the "Save" button
      Then I should see the report "Daily Error Report"

    Scenario: Staff can unselect report
      Given we have report "Daily Error Report"
      And we have selected the report
      When I go to my account page
      And I click on the "Edit" link
      And I uncheck the checkbox for the report "Daily Error Report"
      And I click on the "Save" button
      Then I should not see the report "Daily Error Reports"
