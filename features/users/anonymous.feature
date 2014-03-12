@javascript
Feature: Use without signing in
  In order to use ALM
  Users should not be required to sign in

    Scenario: Anonymous user can see articles
      Given we have a user with role "admin"
      And that we have 5 articles
      When I go to the "Articles" page
      Then I should see a list of 5 articles

    Scenario: Anonymous user can go to article
      Given we have a user with role "admin"
      And there is an article
      When I go to the article
      Then I should see the article

    Scenario: Anonymous user can see sources
      Given we have a user with role "admin"
      And the source "Citeulike" exists
      When I go to the "Sources" page
      Then I should see the image "citeulike.png"

    Scenario: Anonymous user can go to source
      Given we have a user with role "admin"
      And the source "Citeulike" exists
      When I go to the source "CiteULike"
      Then I should see the image "citeulike.png"

   @allow-rescue
    Scenario: Anonymous user cannot see the main admin dashboard
      When I go to the "Home" admin page
      Then I should see the "You need to sign in or sign up before continuing." error message

    @allow-rescue
    Scenario: Anonymous user cannot see sources in the admin dashboard
      When I go to the "Sources" admin page
      Then I should see the "You need to sign in or sign up before continuing." error message

    @allow-rescue
    Scenario: Anonymous user cannot see an individual source in the admin dashboard
      Given the source "Citeulike" exists
      When I go to the admin page of source "Citeulike"
      Then I should see the "You need to sign in or sign up before continuing." error message

    @allow-rescue
    Scenario: Anonymous user cannot see users in the admin dashboard
      When I go to the "Users" admin page
      Then I should see the "You need to sign in or sign up before continuing." error message

    @allow-rescue
    Scenario: Anonymous user cannot see API requests in the admin dashboard
      When I go to the "API Requests" admin page
      Then I should see the "You need to sign in or sign up before continuing." error message

    @allow-rescue
    Scenario: Anonymous user cannot see errors in the admin dashboard
      When I go to the "Alerts" admin page
      Then I should see the "You need to sign in or sign up before continuing." error message

    @allow-rescue
    Scenario: Anonymous user can download the monthly report
      Given we have a monthly article statistics report
      When I go to the URL
      Then I should not see the "The page you were looking for doesn't exist.." error message
