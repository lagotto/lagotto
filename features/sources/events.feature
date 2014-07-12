@javascript
Feature: See events
  In order to make sure that we collect metrics correctly
  An admin user
  Should be able to see the number and sum of events

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists
    And the source "Crossref" exists
    And that we have 5 articles

    Scenario: Events for articles in dashboard
      When I go to the "Articles" tab of the Sources admin page
      Then the chart should show 5 events for "CiteULike"

    Scenario: Events in dashboard
      When I go to the "Events" tab of the Sources admin page
      Then the chart should show 250 events for "CiteULike"

    @not_teamcity
    Scenario: Events in source view
      When I go to the "Summary" tab of source "Citeulike"
      Then the table "SummaryTable" should be:
        |                                             | Articles with Events | All Events |
        | Events                                      | 5                    | 250        |
        |                                             | Pending              | Working    |
        | Jobs                                        |                      |            |
        |                                             | Responses            | Errors     |
        | Responses in the last 24 Hours              |                      |            |
        |                                             | Average              | Maximum    |
        | Response duration in the last 24 Hours (ms) |                      |            |
