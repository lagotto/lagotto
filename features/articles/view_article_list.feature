@javascript
Feature: View article list
  In order to collect metrics
  A user
  Should be able to view a list of articles

    Scenario Outline: Article list
      Given we have a user with role "admin"
      And that we have <Number> articles
      When I go to the "Articles" page
      Then I should see a list of <VisibleNumber> articles

      Examples:
        | Number   | VisibleNumber |
        | 15       | 30            |
        | 60       | 50            |
