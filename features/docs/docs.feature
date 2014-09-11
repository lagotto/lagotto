@javascript
Feature: View documentation
  In order to understand the ALM application
  A user
  Should be able to view documentation

    Scenario: Documentation menu
      When I go to the "Documentation" menu
      Then I should see the "Installation" menu item

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
        | Releases          |
        | Roadmap           |
        | Contributors      |

    Scenario: Documentation on home page
      When I go to the "Home" page
      Then I should see the documentation

    Scenario: Documentation on user page
      Given I am logged in as "user"
      When I go to my account page
      And I click on the "Documentation" tab
      Then I should see the documentation

    Scenario: Documentation on source page
      Given we have a user with role "admin"
      And the source "Citeulike" exists
      When I go to the source "Citeulike"
      And I click on the "Documentation" tab
      Then I should see the documentation

    Scenario: Documentation on source page
      Given I am logged in as "admin"
      And the source "Citeulike" exists
      When I go to the "Documentation" tab of source "Citeulike"
      Then I should see the documentation

    Scenario Outline: Documentation on source page
      Given I am logged in as "admin"
      And the source "<Name>" exists
      When I go to the "Documentation" tab of source "<Name>"
      Then I should see the documentation

      Examples:
        | Name                          |
        | Citeulike                     |
        | Mendeley                      |
        | Crossref                      |
        | Datacite                      |
        | PmcEurope                     |
        | PmcEuropeData                 |
        | PubMed                        |
        | Scopus                        |
        | Wos                           |
        | ArticleCoverage               |
        | ArticleCoverageCurated        |
        | Facebook                      |
        | Reddit                        |
        | Twitter                       |
        | TwitterSearch                 |
        | Wikipedia                     |
        | Wordpress                     |
        | PlosComments                  |
        | Nature                        |
        | Openedition                   |
        | Counter                       |
        | Figshare                      |
        | Copernicus                    |
        | Pmc                           |
        | RelativeMetric                |
        | F1000                         |

    Scenario: Documentation on sources page
      Given I am logged in as "admin"
      When I go to the "Documentation" tab of the Sources page
      Then I should see the documentation
