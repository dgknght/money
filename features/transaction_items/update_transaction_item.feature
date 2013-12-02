Feature: Update a transaction item
  As a user,
  In order to correct a mistake,
  I need to be able to edit a transaction item (in 'by account' view)
  
  Scenario: A user updates a transaction item
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has an asset account named "Checking"
    And entity "Personal" has an expense account named "Groceries"
    And entity "Personal" has an income account named "Salary"
    And entity "Personal" has the following transactions
      | Transaction date | Description | Amount | Debit account | Credit account |
      | 2013-01-01       | Paycheck    |  1_000 | Checking      | Salary         |
      | 2013-01-02       | Kroger      |     50 | Groceries     | Checking       |
    
    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Checking" within the main content
    
    When I click "Checking" within the main content
    Then I should see "Checking Transaction items" within the page title
    And I should see the following transaction items table
     | Transaction date | Description | Account   | Rec. |   Amount |  Balance |
     | 1/1/2013         | Paycheck    | Salary    |      | 1,000.00 | 1,000.00 |
     | 1/2/2013         | Kroger      | Groceries |      |   -50.00 |   950.00 |
     
    When I click "Edit" within the 2nd transaction item row
    Then I should see "Edit transaction item" within the page title
    
    When I fill in "Amount" with "55"
    And I click "Save"    
    Then I should see "The transaction was updated successfully." within the notice area
    And I should see the following transaction items table
     | Transaction date | Description | Account   | Rec. |   Amount |  Balance |
     | 1/1/2013         | Paycheck    | Salary    |      | 1,000.00 | 1,000.00 |
     | 1/2/2013         | Kroger      | Groceries |      |   -55.00 |   945.00 |