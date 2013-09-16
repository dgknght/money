Feature: Delete an account
c  Scenario: A user deletes and account
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an asset account named "Ex-wife's checking"
    And I am signed in as "john@doe.com/please01"
    
    When I am on my home page
    Then I should see the following accounts table
      | Name               | Balance |
      | Assets             | 0.00    |
      | Ex-wife's checking | 0.00    |
      | Liabilities        | 0.00    |
      | Equity             | 0.00    |
      | Income             | 0.00    |
      | Expense            | 0.00    |
      
    When I click "Delete" within the account row for "Ex-wife's checking"
    Then I should see "The account was successfully deleted." within the notice area
    And I should see the following accounts table
      | Name               | Balance |
      | Assets             | 0.00    |
      | Liabilities        | 0.00    |
      | Equity             | 0.00    |
      | Income             | 0.00    |
      | Expense            | 0.00    |