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
        | Roadmap           |
        | Contributors      |

    Scenario: Documentation on home page
      When I go to the "Home" page
      Then I should see the documentation

    Scenario: Documentation on user page
      Given I am logged in as "user"
      When I go to my account page
      And click on the "Documentation" tab
      Then I should see the documentation

    Scenario: Documentation on source page
      Given we have a user with role "admin"
      And the source "Citeulike" exists
      When I go to the source "CiteULike"
      And click on the "Documentation" tab
      Then I should see the documentation

    Scenario: Documentation on source admin page
      Given I am logged in as "admin"
      And the source "Citeulike" exists
      When I go to the "Documentation" tab of source "CiteULike"
      Then I should see the documentation

    @wip
    Scenario Outline: Documentation on source admin page
      Given I am logged in as "admin"
      And the source "<Name>" exists
      When I go to the "Documentation" tab of source "<Name>"
      Then I should see the documentation

      Examples:
        | Name                          |
        | CiteULike                     |
        | Mendeley                      |
        | CrossRef                      |
        | DataCite                      |
        | PMC Europe Citations          |
        | PMC Europe Database Citations |
        | PubMed Central                |
        | Scopus                        |
        | Web of Science®               |
        | Article Coverage              |
        | Article Coverage Curated      |
        | Facebook                      |
        | Reddit                        |
        | Twitter                       |
        | Twitter (Search API)          |
        | Wikipedia                     |
        | Wordpress.com                 |
        | Journal Comments              |
        | Nature                        |
        | OpenEdition                   |
        | Counter                       |
        | Figshare                      |
        | Copernicus                    |
        | PubMed Central Usage Stats    |
        | Relative Metric               |
        | F1000Prime                    |

    Scenario: Documentation on sources admin page
      Given I am logged in as "admin"
      When I go to the "Documentation" tab of the Sources admin page
      Then I should see the documentation