@couchdb
Feature: View CouchDB size
  In order to understand the status of the application
  An admin user
  Should be able to view the number and total size of CouchDB documents
  
  Background:
    Given I am logged in
    And that we have added 3 documents to CouchDB
    
    @javascript
    Scenario: CouchDB info
      When I go to the "Home" admin page
      Then I should see that CouchDB has 3 documents