Feature: Add an attachment
  As a user
  In order to keep track of receipts an other documents
  I need to be able to save them with a transaction

  Scenario: A user saves an attachment to a transaction
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has an asset account named "Checking"
    And entity "Personal" has an income account named "Salary"
    And entity "Personal" has a transaction "Paycheck" on 1/1/2014 crediting "Salary" $1,000 and debiting "Checking" $1,000

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Transactions" within the navigation

    When I click "Transactions" within the navigation
    Then I should see "Transactions" within the page title
    And I should see the following transactions table
      | Transaction Date | Description |   Amount | 
      | 1/1/2014         | Paycheck    | 1,000.00 |

    When I click "Attachments" within the 1st transaction row
    Then I should see "Attachments" within the page title

    When I click "Add"
    Then I should see "New attachment" within the page title

    When I specify the file "attachment.png" for "File"
    And I click "Save"

    Then I should see "The attachment was saved successfully" within the notice area
    And I should see the following attachments table
      | Name           | Content type |
      | attachment.png | image/png    |
