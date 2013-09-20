Feature: Enter a transaction
  Scenario: A user enters a transaction:
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an asset account named "Checking" with a balance of 100.00
    And user "john@doe.com" has an expense account named "Groceries" with a balance of 0.00
    And user "john@doe.com" has an equity account named "Retained" with a balance of 0.00
    And I am signed in as "john@doe.com/please01"

    When I am on my home page
    Then I should see the following accounts table
      | Name        | Balance |
      | Assets      |   0.00  |
      | Checking    | 100.00  |
      | Liabilities |   0.00  |
      | Equity      |   0.00  |
      | Retained    |   0.00  |
      | Income      |   0.00  |
      | Expense     |   0.00  |
      | Groceries   |   0.00  |

    When I click "Checking" within the account row for "Checking"
    Then I should see "Checking" within the page title

    When I fill in "Description" with "Kroger"

    And I fill in the 1st transaction items amount field with "56.65"
    And I select "credit" from the 1st transaction items action list

    And I fill in the 2nd transaction items amount field with "56.65"
    And I select "Groceries" from the 2nd transaction items account_id list
    And I select "debit" from the 2nd transaction items action list

    And I click "Submit"
    Then I should see "The transaction was created successfully." within the notice area

    When I click "Home" within the navigation
    Then I should see the following accounts table
      | Name        | Balance |
      | Assets      |   0.00  |
      | Checking    |  43.35  |
      | Liabilities |   0.00  |
      | Equity      |   0.00  |
      | Retained    |   0.00  |
      | Income      |   0.00  |
      | Expense     |   0.00  |
      | Groceries   |  56.65  |
