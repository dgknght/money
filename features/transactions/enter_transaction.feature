@wip
Feature: Enter a transaction
  Scenario: A user enters a transaction:
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    
    And entity "Personal" has the following accounts
      | Name             | Account type |
      | Checking         | asset        |
      | Groceries        | expense      |
      | Opening balances | equity       |
    And entity "Personal" has the following transactions
      | Description     | Transaction date | Amount | Debit account | Credit account   |
      | Opening balance |       2014-01-01 |    100 | Checking      | Opening balances |
    And I am signed in as "john@doe.com/please01"

    When I am on the "Personal" entity page
    Then I should see "Transactions" within the navigation
    And I should see the following accounts table
      | Name             | Balance |
      | Assets           | 100.00  |
      | Checking         | 100.00  |
      | Liabilities      |   0.00  |
      | Equity           | 100.00  |
      | Opening balances | 100.00  |
      | Income           |   0.00  |
      | Expense          |   0.00  |
      | Groceries        |   0.00  |

    When I click "Transactions" within the navigation
    Then I should see "Transactions" within the page subtitle

    When I fill in "description" with "Kroger"
    And I fill in "memo" with "Food for dinner party"
    And I fill in "confirmation" with "123456"

    And I fill in the 1st transaction items amount field with "56.65"
    And I select "credit" from the 1st transaction items action list

    And I fill in the 2nd transaction items amount field with "56.65"
    And I select "Groceries" from the 2nd transaction items account_id list
    And I select "debit" from the 2nd transaction items action list

    And I click "Save"
    Then I should see "The transaction was created successfully." within the notice area
    And I should see the following transactions table
      | Transaction date | Description     | Amount | Memo                  | Confirmation |
      |         1/1/2014 | Opening balance | 100.00 |                       |              |
      |         1/2/2014 | Kroger          |  56.65 | Food for dinner party | 123456       |

    When I click "Back"
    Then I should see "Transactions" within the page title

    When I click "Back"
    Then I should see the following accounts table
      | Name              | Balance |
      | Assets            |   43.35 |
      | Checking          |   43.35 |
      | Liabilities       |    0.00 |
      | Equity            |   43.35 |
      | Opening balances  |  100.00 |
      | Retained earnings |  -56.65 |
      | Income            |    0.00 |
      | Expense           |   56.65 |
      | Groceries         |   56.65 |
