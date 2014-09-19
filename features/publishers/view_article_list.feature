@javascript
Feature: View article list
  In order to collect metrics
  A user
  Should be able to view a list of articles for a publisher

    Scenario: Article list
      Given we have a user with role "admin"
      And we hava a publisher with name "Public Library of Science (PLoS)" and CrossRef ID 340
      And that we have 10 articles
      When I go to the page of publisher "Public Library of Science (PLoS)"
      Then I should see a list of 10 articles
