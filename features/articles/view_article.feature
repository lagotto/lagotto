Feature: View article list
  In order to collect metrics
  A user
  Should be able to view a list of articles
  
    Scenario: Article list
      Given that we have 20 articles
      When I go to the Article page
      Then I should see a list of 20 articles
      
    Scenario: Paginated article list
      Given that we have 60 articles
      When I go to the Article page
      Then I should see a list of 50 articles