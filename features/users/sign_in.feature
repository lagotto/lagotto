Feature: Sign in
  In order to get access to protected sections of the site
  A user
  Should be able to sign in

    Scenario: User signs in
      Given I am not logged in
      When I sign in
      Then I should be signed in