Feature: View transaction items by account
  As a user,
  In order to understand the state of an account
  I need to be able to see transactions items for only that account
  
  Scenario: A user views all transaction items for an account
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has an asset account named "Checking"
    And entity "Personal" has an income account named "Salary"
    And entity "Personal" has an expense account named "Groceries"
    And entity "Personal" has the following transactions
      | Transaction date | Description | Amount | Credit account | Debit account |
      | 2013-01-01       | Paycheck    |  5,000 | Salary         | Checking      |
      | 2013-01-02       | Kroger      |     45 | Checking       | Groceries     |
    
    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Accounts" within the navigation
    
    When I click on "Accounts" within the navigation
    Then I should see "Accounts" within the page title
    
    When I click on "Checking" within the main content
    Then I should see "Transaction items" within the page title
    And I should see the following transaction items table
      | Transaction date | Description | Account   | Reconciled | Amount   |  Balance |
      | 1/1/2013         | Paycheck    | Salary    |            | 5,000.00 | 5,000.00 |
      | 1/2/2013         | Kroger      | Groceries |            |   -45.00 | 4,955.00 |
