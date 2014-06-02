@javascript
Feature: See donut visualizations for source
  In order to make sure that we collect metrics correctly
  An admin user
  Should be able to see the status and events

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists
    And that we have 5 articles

    Scenario Outline: See donut
    When I go to the "Summary" tab of source "Citeulike"
    Then I should see the donut "<Name>"

    Examples:
    | Name   |
    | status |
    | day    |
    | month  |

    # @javascript
    # Scenario Outline: See tooltip
    # When I go to the "Summary" tab of source "Citeulike"
    # And I hover over the donut "<Name>"
    # Then I should see the tooltip
    #
    # Examples:
    # | Name   |
    # | status |
    # | day    |
    # | month  |