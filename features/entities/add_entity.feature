Feature: Add an entity
  Scenario: A user adds a new entity
    Given there is a user with email address "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"
    
    When I am on my home page
    
    Then I should see "Entities" within the page title
      
    When I click "Add" within the main content
    Then I should see "New entity" within the page title
    
    When I fill in "Name" with "Personal"
    And I click "Save"
    
    Then I should see "The entity was created successfully." within the notice area
    Then I should see "Accounts" within the page title
    And I should see the following accounts table
      | Name        | Balance |
      | Assets      |    0.00 |
      | Liabilities |    0.00 |
      | Equity      |    0.00 |
      | Income      |    0.00 |
      | Expense     |    0.00 |
