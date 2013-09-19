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
        | Alerts            |
        | FAQ               |
        | Roadmap           |
        | Past-Contributors |

    Scenario: Documentation on user page
      Given I am logged in as "user"
      When I go to my account page
      Then I should see the "API Documentation" title

    Scenario: Documentation on source page
      Given the source "Citeulike" exists
      When I go to the source "CiteULike"
      And click on the "Documentation" tab
      Then I should see the "Documentation" sidebar

    Scenario: Documentation on source admin page
      Given I am logged in as "admin"
      And the source "Citeulike" exists
      When I go to the "Documentation" tab of source "CiteULike"
      Then I should see the "Documentation" sidebar
