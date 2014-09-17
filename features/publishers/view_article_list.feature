@javascript
Feature: View article list
  In order to collect metrics
  A user
  Should be able to view a list of articles for a publisher

    Scenario Outline: Article list
      Given we have a user with role "admin"
      And the publisher "Public Library of Science (PLoS)" exists
      And that we have 10 articles
      When I go to the page of publisher "Public Library of Science (PLoS)"
      Then I should see a list of 10 articles
