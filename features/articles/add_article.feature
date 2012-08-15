Feature: Add article
  In order to collect metrics
  A user
  Should be able to add an article
  
    Background:
      Given I am logged in
  
    Scenario: Article is added succesfully
      Given an article does not exist
      When I add the article with all required information
      Then I should see the article