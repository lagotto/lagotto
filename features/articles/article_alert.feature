@javascript
Feature: View article alert
  In order to collect metrics
  A user
  Should be able to see alerts for an article

  Background:
  Given the source "Citeulike" exists
  And I am logged in as "admin"
  And there is an article with alerts

    Scenario: I should see the alerts navigation menu
      When I go to the "Articles" page
      Then I should see the "article-alerts" menu

    Scenario: I should see the alerts for an article
      When I go to the article
      Then I should see the alert for the article

    Scenario: Deleting alert
      When I go to the article
      And click on the "Alerts" tab
      And I click on the "by Message" menu item of the Delete button of the first alert and confirm
      Then I should see 0 alerts
