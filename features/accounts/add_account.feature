Feature: Add a new account
  Scenario: A user adds a new asset account
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Business"
    And I am signed in as "john@doe.com/please01"
    
    When  I am on my home page
    Then I should see the following entities table
      | Name     |
      | Business |
      
    When I click "Business" within the entities table
    Then I should see "Accounts" within the page title
    And I should see the following accounts table
      | Name        | Balance |
      | Assets      | 0.00    |
      | Liabilities | 0.00    |
      | Equity      | 0.00    |
      | Income      | 0.00    |
      | Expense     | 0.00    |
    
    When I click "Add" within the main content
    Then I should see "New account" within the page title
    
    When I fill in "Name" with "Checking"
    And I click "Save"
    
    Then I should see "The account was successfully created." within the notice area
    And I should see the following accounts table
      | Name        | Balance |
      | Assets      | 0.00    |
      | Checking    | 0.00    |
      | Liabilities | 0.00    |
      | Equity      | 0.00    |
      | Income      | 0.00    |
      | Expense     | 0.00    |
