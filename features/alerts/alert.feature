@javascript
Feature: Show alerts
  In order to make sure that we collect metrics correctly
  An admin user
  Should see alerts

  Background:
    Given I am logged in as "admin"

    Scenario: Seeing a list of alerts
      Given we have 1 alert
      When I go to the "Alerts" page
      Then I should see 1 alert

    Scenario Outline: Seeing alert information
      Given we have 1 alert
      When I go to the "Alerts" page
      Then I should see the "<Message>" error
      And I should not see the "<ClassName>" class name

      Examples:
        | Message                | ClassName               |
        | The request timed out. | Net::HTTPRequestTimeOut |

    Scenario Outline: Seeing alert details
      Given we have 1 alert
      When I go to the "Alerts" page
      And I click on the "[408] The request timed out." link
      Then I should see the "<Message>" error
      And I should see the "<ClassName>" class name

      Examples:
        | Message                 | ClassName               |
        | The request timed out.  | Net::HTTPRequestTimeOut |

    @allow-rescue
    Scenario Outline: Alerts
      When I go to "<Path>"
      Then I should see the "<Alert>" error message

      Examples:
        | Path        | Alert                        |
        | /articles/x | ActiveRecord::RecordNotFound |
        | /x          | No route matches [GET] "/x"  |

    Scenario: Seeing multiple alerts
      Given we have 25 alerts
      When I go to the "Alerts" page
      And I go to page 2
      Then I should see 10 alerts

    Scenario: Deleting alert
      Given we have 25 alerts
      When I go to the "Alerts" page
      And I go to page 2
      And I click on the "by Message" menu item of the Delete button of the first alert and confirm
      Then I should see 0 alerts
