Feature: Add Nature Blogs content
  In order to collect metrics
  A user
  Should be able to add Nature Blogs counts for an article

  Background:
    Given I am logged in
    And there is an article
  
  @wip
  Scenario: User fails to refresh article
    Given that an article has no blog count
    When I refresh an article
    Then I should not see a blog count
    
