@javascript
Feature: View article list
  In order to collect metrics
  A user
  Should be able to view a list of articles

    @not_teamcity
    Scenario Outline: Article list
      Given we have a user with role "admin"
      And that we have <Number> articles
      When I go to the "Articles" page
      Then I should see a list of <VisibleNumber> articles

      Examples:
        | Number   | VisibleNumber |
        | 15       | 15            |
        | 60       | 50            |
