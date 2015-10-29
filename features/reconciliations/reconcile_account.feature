Feature: Reconcile an account
  As a user,
  In order to ensure my account records are in agreement with the bank's
  I need to be able to reconcile an account against a bank statement
  
  Scenario: A user reconciles an account
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has an asset account named "Checking"
    And entity "Personal" has an income account named "Salary"
    And entity "Personal" has an expense account named "Groceries"
    And entity "Personal" has the following transactions
      | Transaction date | Description |   Amount | Credit account | Debit account |
      | 2013-01-01       | My Employer |    5,000 | Salary         | Checking      |
      | 2013-01-06       | Kroger      |       40 | Checking       | Groceries     |
      | 2013-01-13       | Kroger      |       40 | Checking       | Groceries     |
      | 2013-01-15       | My Employer |    5,000 | Salary         | Checking      |
      | 2013-01-20       | Kroger      |       40 | Checking       | Groceries     |
      | 2013-01-27       | Kroger      |       40 | Checking       | Groceries     |
      | 2013-02-03       | Kroger      |       40 | Checking       | Groceries     |
  
  When I am signed in as "john@doe.com/please01"
  And I am on the "Personal" entity page
  Then I should see "Accounts" within the navigation
  
  When I click "Accounts" within the navigation
  Then I should see "Accounts" within the page title
  Then I should see the following accounts table
    | Name              |   Balance |
    | Assets            |  9,800.00 |
    | Checking          |  9,800.00 |
    | Liabilities       |      0.00 |
    | Equity            |  9,800.00 |
    | Retained earnings |  9,800.00 |
    | Income            | 10,000.00 |
    | Salary            | 10,000.00 |
    | Expense           |    200.00 |
    | Groceries         |    200.00 |
  
  When I click the reconcile button within the account row for "Checking"
  Then I should see "Checking reconciliation" within the page title
  And I should see the following transactions table
    |      Date | Description |   Amount |
    |  1/1/2013 | My Employer | 5,000.00 |
    |  1/6/2013 | Kroger      |   -40.00 |
    | 1/13/2013 | Kroger      |   -40.00 |
    | 1/15/2013 | My Employer | 5,000.00 |
    | 1/20/2013 | Kroger      |   -40.00 |
    | 1/27/2013 | Kroger      |   -40.00 |
    |  2/3/2013 | Kroger      |   -40.00 |

  When I fill in "reconciliation_reconciliation_date" with "2013-01-31"
  And I fill in "reconciliation_closing_balance" with "9840"
  And I check the box within the 1st transaction row
  And I check the box within the 2nd transaction row
  And I check the box within the 3rd transaction row
  And I check the box within the 4th transaction row
  And I check the box within the 5th transaction row
  And I check the box within the 6th transaction row
  And I click "Save"
  Then I should see "The account was reconciled successfully." within the notice area
  And I should see "Transaction items" within the page title
  
  When I click "Reconcile"
  Then I should see "Checking reconciliation" within the page title
  And I should see the following reconciliation attributes
    |            | Date      |  Balance |
    | Previous   | 1/31/2013 | 9,840.00 |
    | Current    |           |          |
    | Cleared    |           | 9,840.00 |
    | Difference |           |     0.00 |
    
  And I should see the following transactions table
    |     Date | Description |   Amount |
    | 2/3/2013 | Kroger      |   -40.00 |
  
