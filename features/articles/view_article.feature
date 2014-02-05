@javascript
Feature: View article
  In order to collect metrics
  A user
  Should be able to see identifiers for an article

  Background:
    Given the source "Citeulike" exists

    Scenario: No other article identifiers
      When I go to the article with the DOI "10.1371/journal.pone.000001" and no other identifiers
      Then I should see the DOI "10.1371/journal.pone.000001" as a link
      And I should see "October 23, 2012" with the "Publication Date" for the article
      And I should not see the "PubMed ID" for the article
      And I should not see the "PubMed Central ID" for the article
      And I should not see the "Mendeley UUID" for the article
      And I should not see the "URL" for the article

    Scenario Outline: Article identifiers
      When I go to the article with "<Value>" for "<Identifier>"
      Then I should see "<Value>" with the "<Label>" for the article

      Examples:
      | Identifier      | Value                                                                      | Label             |
      | pub_med         | 17183632                                                                   | PubMed ID         |
      | pub_med_central | 1762354                                                                    | PubMed Central ID |
      | mendeley        | 1779fd30-6d0c-11df-a2b2-0026b95e3eb7                                       | Mendeley UUID     |
      | url             | http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000010 | URL               |