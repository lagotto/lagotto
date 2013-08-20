@javascript
Feature: Show errors
  In order to make sure that we collect metrics correctly
  An admin user
  Should see errors

  Background:
    Given I am logged in as "admin"

    Scenario: Seeing a list of errors
      Given we have 1 error message
      When I go to the "Errors" admin page
      Then I should see 1 error message

    Scenario Outline: Seeing error information
      Given we have 1 error message
      When I go to the "Errors" admin page
      Then I should see the "<Message>" error message
      And I should not see the "<ClassName>" class name

      Examples:
        | Message                | ClassName               |
        | The request timed out. | Net::HTTPRequestTimeOut |

    Scenario Outline: Seeing error details
      Given we have 1 error message
      When I go to the "Errors" admin page
      And I click on the "[408] The request timed out." link
      Then I should see the "<Message>" error message
      And I should see the "<ClassName>" class name

      Examples:
        | Message                 | ClassName               |
        | The request timed out.  | Net::HTTPRequestTimeOut |

    @allow-rescue
    Scenario Outline: Errors
      When I go to "<Path>"
      Then I should see the "<ErrorMessage>" error message

      Examples:
        | Path        | ErrorMessage                |
        | /articles/x | No record for "x" found     |
        | /x          | No route matches [GET] "/x" |

    Scenario: Seeing multiple error pages
      Given we have 25 error messages
      When I go to the "Errors" admin page
      And I go to page 2
      Then I should see 5 error messages

    Scenario: Deleting error message
      Given we have 25 error messages
      When I go to the "Errors" admin page
      And I go to page 2
      And I click on the "by Message" menu item of the Delete button of the first error message and confirm
      Then I should see 0 error messages
