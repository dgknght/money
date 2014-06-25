Feature: Add a child account
  As a user
  In order to organize my accounts
  I need to be able to nest a child account under a parent account
  
  Scenario: A user adds a child account
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following accounts
      | Name      | Account type | Content type |
      | Groceries | expense      | currency     |
      | Checking  | asset        | currency     |
      | Opening   | equity       | currency     |
    And entity "Personal" has the following transactions
      | Description     | Transaction date | Amount | Debit account | Credit account |
      | Opening Balance |       2014-01-01 |    100 | Checking      | Opening        |
    And I am signed in as "john@doe.com/please01"
    
    When I am on the "Personal" entity page
    Then I should see the following accounts table
      | Name        | Balance | 
      | Assets      |  100.00 |
      | Checking    |  100.00 |
      | Liabilities |    0.00 |
      | Equity      |  100.00 |
      | Opening     |  100.00 |
      | Income      |    0.00 |
      | Expense     |    0.00 |
      | Groceries   |    0.00 |
      
    When I click "Add" within the main content area
    Then I should see "New account" within the page title
    
    When I select "expense" from the "Account type" list
    And I fill in "Name" with "Food"
    And I select "Groceries" from the "Parent" list
    And I click "Save"    
    Then I should see "The account was successfully created." within the notice area
    And I should see the following accounts table
      | Name        | Balance |
      | Assets      |  100.00 |
      | Checking    |  100.00 |
      | Liabilities |    0.00 |
      | Equity      |  100.00 |
      | Opening     |  100.00 |
      | Income      |    0.00 |
      | Expense     |    0.00 |
      | Groceries   |    0.00 |
      | Food        |    0.00 |
    
    When I enter a transaction for entity "Personal" called "Kroger" on 1/1/2013 crediting "Checking" $15 and debiting "Food" $15
    And I click "Back"
    Then I should see the following accounts table
      | Name              | Balance |
      | Assets            |   85.00 |
      | Checking          |   85.00 |
      | Liabilities       |    0.00 |
      | Equity            |   85.00 |
      | Opening           |  100.00 |
      | Retained earnings |  -15.00 |
      | Income            |    0.00 |
      | Expense           |   15.00 |
      | Groceries         |   15.00 |
      | Food              |   15.00 |
