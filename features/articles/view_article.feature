Feature: View article list
  In order to collect metrics
  A user
  Should be able to view a list of articles
    
    @javascript
    Scenario: Article list
      Given that we have 15 articles
      When I go to the "Articles" page
      Then I should see a list of 15 articles
      
    @javascript
    Scenario: Paginated article list
      Given that we have 60 articles
      When I go to the "Articles" page
      Then I should see a list of 50 articles