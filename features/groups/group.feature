Feature: Edit groups
  In order to organize sources
  A user
  Should be able to add, edit or delete a group
  
    Background:
      Given I am logged in
      And I have a group "Citations"
      
    @javascript
    Scenario: Group is added succesfully
      When I add the group "Statistics"
      Then I should see the group "Statistics"
  
    @javascript
    Scenario: Group is changed succesfully
      When I change the name of group "Citations" to "Statistics"
      Then I should see the group "Statistics"
    
    @javascript    
    Scenario: Name for group missing
      When I change the name of group "Citations" to ""
      Then I should see the error "can't be blank"
    
    @javascript
    Scenario: Group exists already
      When I add the group "Statistics"
      And I change the name of group "Citations" to "Statistics"
      Then I should see the error "has already been taken"
    
    @javascript  
    Scenario: Group is deleted succesfully
      When I delete the group "Citations"
      Then I should not see the group "Citations"