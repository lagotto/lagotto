@javascript
Feature: Edit sources
  In order to collect metrics
  An admin user
  Should be able to see and edit source settings

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists

    Scenario: Group must be selected
      When I edit the source "CiteULike"
      Then "Saved" should be the only option for "Group"

    Scenario: Content from settings.yml should be displayed
      When I go to the "Configuration" tab of source "CiteULike"
      Then I should see the "Job batch size" settings
      And I should see the "Batch time interval" settings
      And I should see the "Staleness interval" settings
      And I should see the "Requests per day" settings

    Scenario: Source overview should display source image
      When I go to the "Sources" page
      Then I should see the image "citeulike.png"

    Scenario: Source should display source image
      When I go to the admin page of source "CiteULike"
      Then I should see the image "citeulike.png"


