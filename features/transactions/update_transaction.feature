Feature: Update a transaction
  As a user,
  In order to correct a transaction with an error,
  I need to be able to update the transaction
  
  Scenario: A user updates a transaction
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following accounts
      | Name             | Account type |
      | Checking         | asset        |
      | Groceries        | expense      |
      | Gasoline         | expense      |
      | Opening balances | equity       |
    And entity "Personal" has the following transactions
      | Description | Transaction date | Amount | Debit account | Credit account   |
      | Opening bal.|         1/1/2013 |    900 | Checking      | Opening balances |
      | Kroger      |         1/1/2013 |    100 | Groceries     | Checking         |
    
    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Transactions" within the navigation
    And I should see the following accounts table
      | Name              | Balance |
      | Assets            |  800.00 |
      | Checking          |  800.00 |
      | Liabilities       |    0.00 |
      | Equity            |  800.00 |
      | Opening balances  |  900.00 |
      | Retained earnings | -100.00 |
      | Income            |    0.00 |
      | Expense           |  100.00 |
      | Gasoline          |    0.00 |
      | Groceries         |  100.00 |
    
    When I click "Transactions" within the navigation
    Then I should see the following transactions table
      |     Date | Description  | Amount |
      | 1/1/2013 | Opening bal. | 900.00 |
      | 1/1/2013 | Kroger       | 100.00 |
      
    When I click the edit button within the 2nd transaction row
    And I select "Gasoline" from the "Account" list with "Groceries" selected
    And I click "Save"
    Then I should see "The transaction was updated successfully." within the notice area
    
    When I click on "Accounts" within the navigation
    Then I should see the following accounts table
      | Name              | Balance |
      | Assets            |  800.00 |
      | Checking          |  800.00 |
      | Liabilities       |    0.00 |
      | Equity            |  800.00 |
      | Opening balances  |  900.00 |
      | Retained earnings | -100.00 |
      | Income            |    0.00 |
      | Expense           |  100.00 |
      | Gasoline          |  100.00 |
      | Groceries         |    0.00 |
