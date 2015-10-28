Feature: Delete an attachment
  As a user
  In order to discard an attachment that I do not need
  I need to be able to delete the attachment

  Scenario: A user deletes an attachment
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has an asset account named "Checking"
    And entity "Personal" has an income account named "Salary"
    And entity "Personal" has a transaction "Paycheck" on 1/1/2014 crediting "Salary" $1,000 and debiting "Checking" $1,000
    And the transaction "Paycheck" on 1/1/2014 has an attachment named "Paystub"

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Transactions" within the navigation

    When I click "Transactions" within the navigation
    Then I should see "Transactions" within the page title
    And I should see the following transactions table
      | Date     | Description |   Amount |
      | 1/1/2014 | Paycheck    | 1,000.00 |

    When I click the attachments button within the 1st transaction row
    Then I should see "Attachments" within the page title
    And I should see the following attachments table
      | Name    | Content type |
      | Paystub | image/png    |

    When I click the delete button within the 1st attachment row
    Then I should see "The attachment was removed successfully." within the notice area
    And I should see the following attachments table
      | Name    | Content type |
