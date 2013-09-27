@wip
Feature: View transactions
  Scenario: A user views all transactions for an entity
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Business"
    And entity "Business" has an asset account named "Checking"
    And entity "Business" has an expense account named "Office Supplies"
    And entity "Business" has a transaction "Office Max" on 1/1/2013 crediting "Checking" $100 and debiting "Office Supplies" $100
    
    When I am signed in as "john@doe.com/please01"
    And I am on the "Business" entity page
    Then I should see "Transactions" within the secondary navigation
    
    When I click "Transactions" within the secondary navigation
    Then I should see "Transactions" within the page subtitle
    And I should see the following transactions table
      | Date     | Description | Amount |
      | 1/1/2013 | Office Max  | 100.00 |