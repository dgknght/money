@wip
Feature: Delete a transaction
  As a user, 
  In order to discard a transaction created in error
  I need to be able to delete the transaction
  
  Scenario: A user deletes a transaction
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has an asset account named "Checking"
    And entity "Personal" has an expense account named "Groceries"
    And entity "Personal" has an expense account named "Gasoline"
    And entity "Personal" has a transaction "Kroger" on 1/1/2013 crediting "Checking" $100 and debiting "Groceries" $100
    And entity "Personal" has a transaction "Kroger" on 1/2/2013 crediting "Checking" $100 and debiting "Groceries" $100
    
    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Transactions" within the navigation
    
    When I click "Transactions" within the navigation
    Then I should see the following transactions table
      | Transaction Date | Description | Amount |
      | 1/1/2013         | Kroger      | 100.00 |
      | 1/2/2013         | Kroger      | 100.00 |
    
    When I click "Delete" within the 1st transaction row
    Then I should see "The transaction was removed successfully." within the notice area
    And I should see the following transactions table
      | Transaction Date | Description | Amount |
      | 1/2/2013         | Kroger      | 100.00 |
