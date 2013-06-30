@javascript
Feature: Sign in as staff
  In order to monitor ALM
  Staff users should be able to see the admin dashboard
  
  Background:
    Given I am logged in as "staff"
      
    @not-teamcity
    Scenario: Staff can see jobs in source view
      Given the source "Citeulike" exists
      And that we have 5 articles
      When I go to the "Summary" tab of source "CiteULike"
      Then the table "SummaryTable" should be:
        |                                | Pending              | Working    |
        | Jobs                           | 0                    | 0          |
        |                                | Responses            | Errors     |
        | Responses in the last 24 Hours | 0                    | 0          |
        |                                | Articles with Events | All Events |
        | Events                         | 5                    | 250        |
    
    Scenario: Content from settings.yml should be displayed
      Given the source "Citeulike" exists
      When I go to the "Configuration" tab of source "CiteULike"
      Then I should see the "Job batch size" settings
      And I should see the "Batch time interval" settings
      And I should see the "Staleness interval" settings
      And I should see the "Requests per day" settings
             
    Scenario: Staff cannot edited sources
      Given the source "Citeulike" exists
      When I go to the "Configuration" tab of source "CiteULike"
      Then I should not see the "Edit" button
      
    Scenario: Staff cannot delete errors
      Given we have 1 error message
      When I go to the "Errors" admin page
      And I click on the "[408] The request timed out." link
      Then I should not see the "Delete" button