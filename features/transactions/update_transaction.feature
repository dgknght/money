@wip
Feature: Update a transaction
  As a user,
  In order to correct a transaction with an error,
  I need to be able to update the transaction
  
  Scenario: A user updates a transaction
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has an asset account named "Checking"
    And entity "Personal" has an expense account named "Groceries"
    And entity "Personal" has an expense account named "Gasoline"
    And entity "Personal" has a transaction "Kroger" on 1/1/2013 crediting "Checking" $100 and debiting "Groceries" $100
    
    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Transactions" within the navigation
    
    When I click "Transactions" within the navigation
    Then I should see the following transactions table
      | Transaction Date | Description | Amount |
      | 1/1/2013         | Kroger      | 100.00 |
      
    When I click on "Kroger" within the 1st transaction row
    And I select "Gasoline" from the "transaction_items_attributes_1_account_id" list within the 2nd transaction item row
    And I click "Save"
    Then I should see "The transaction was updated successfully." within the notice area
    
    When I click on "Accounts" within the navigation
    Then I should see the following accounts table
      | Name        | Balance |
      | Assets      | -100.00 |
      | Checking    | -100.00 |
      | Liabilities |    0.00 |
      | Equity      |    0.00 |
      | Income      |    0.00 |
      | Expense     |  100.00 |
      | Gasoline    |  100.00 |
      | Groceries   |    0.00 |