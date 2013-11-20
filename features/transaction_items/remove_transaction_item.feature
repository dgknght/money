Feature: Remove transaction item
  As a user,
  In order to correct a mistake,
  I need to be able to remove a transaction at the transaction item level
  
  Background:
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has an asset account named "Checking"
    And entity "Personal" has an income account named "Salary"
    And entity "Personal" has an expense account named "Groceries"
    And entity "Personal" has the following transactions
      | Transaction date | Description |   Amount | Credit account | Debit account |
      |       2013-01-01 | Paycheck    | 5,000.00 | Salary         | Checking      |
      |       2013-01-02 | Kroger      |    35.00 | Checking       | Groceries     |
      |       2013-01-02 | Kroger      |    36.00 | Checking       | Groceries     |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Checking" within the main content
    
  Scenario: A user removes a transaction
    When I click "Checking" within the main content
    Then I should see "Transaction items" within the page title
    And I should see the following transaction items table
      | Transaction date | Description | Account   | Rec. |   Amount |  Balance |
      |         1/1/2013 | Paycheck    | Salary    |      | 5,000.00 | 5,000.00 |
      |         1/2/2013 | Kroger      | Groceries |      |   -35.00 | 4,965.00 |
      |         1/2/2013 | Kroger      | Groceries |      |   -36.00 | 4,929.00 |
    
    When I click "Delete" within the 2nd transaction item row
    Then I should see "The transaction was deleted successfully." within the notice area
    And I should see the following transaction items table
      | Transaction date | Description | Account   | Rec. |   Amount |  Balance |
      |         1/1/2013 | Paycheck    | Salary    |      | 5,000.00 | 5,000.00 |
      |         1/2/2013 | Kroger      | Groceries |      |   -36.00 | 4,964.00 |
  
  Scenario: A user tries to remove a reconciled transaction item
    Given I have reconciled account "Checking" as of 1/2/2013 at a balance of $4,964.00 including the following items
      | Transaction date |   Amount |
      | 1/1/2013         | 5,000.00 |
      | 1/2/2013         |    36.00 |
    
    When I click "Checking" within the main content
    Then I should see "Transaction items" within the page title
    And I should see the following transaction items table
      | Transaction date | Description | Account   | Rec. |   Amount |  Balance |
      |         1/1/2013 | Paycheck    | Salary    |  X   | 5,000.00 | 5,000.00 |
      |         1/2/2013 | Kroger      | Groceries |      |   -35.00 | 4,965.00 |
      |         1/2/2013 | Kroger      | Groceries |  X   |   -36.00 | 4,929.00 |
    
    When I click "Delete" within the 3rd transaction item row
    Then I should see "The transaction item has already been reconciled. Undo the reconciliation, then delete the item." within the error area
    And I should see the following transaction items table
      | Transaction date | Description | Account   | Rec. |   Amount |  Balance |
      |         1/1/2013 | Paycheck    | Salary    |  X   | 5,000.00 | 5,000.00 |
      |         1/2/2013 | Kroger      | Groceries |      |   -35.00 | 4,965.00 |
      |         1/2/2013 | Kroger      | Groceries |  X   |   -36.00 | 4,929.00 |
