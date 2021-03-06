Feature: Update an existing account
  Scenario: A user updates an existing account
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Business"
    And entity "Business" has an asset account named "Checking"
    And I am signed in as "john@doe.com/please01"
    
    When I am on the "Business" entity page
    Then I should see the following accounts table
      | Name        | Balance |
      | Assets      | 0.00    |
      | Checking    | 0.00    |
      | Liabilities | 0.00    |
      | Equity      | 0.00    |
      | Income      | 0.00    |
      | Expense     | 0.00    |
      
  When I click the edit button within the account row for "Checking"
  Then I should see "Edit account" within the page title
  
  When I fill in "Name" with "Savings"
  And I click "Save"
  
  Then I should see "The account was successfully updated" within the notice area
  And I should see the following accounts table
      | Name        | Balance |
      | Assets      | 0.00    |
      | Savings     | 0.00    |
      | Liabilities | 0.00    |
      | Equity      | 0.00    |
      | Income      | 0.00    |
      | Expense     | 0.00    |
