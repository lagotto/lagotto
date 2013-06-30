@javascript
Feature: View documentation
  In order to understand the ALM application
  A user
  Should be able to view documentation
    
    Scenario Outline: Documentation
      When I go to the "<Name>" documentation page
      Then I should see the "<Name>" title
      
      Examples: 
        | Name              |
        | Installation      |
        | Setup             |
        | Sources           |
        | API               |
        | Rake              |
        | FAQ               |
        | Version-History   |
        | Roadmap           |
        | Past-Contributors |