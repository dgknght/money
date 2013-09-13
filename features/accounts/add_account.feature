Feature: Add a new account
  Scenario: A user adds a new asset account
    Given there is a user with email address "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"
    And I am on my home page
    
    When I click "Add" within the main content
    Then I should see "New account" within the page title
    
    When I fill in "Name" with "Checking"
    And I click "Save"
    
    Then I should see "The account was successfully created." within the notice area
    And I should see the following account attributes
      | Account type  | asset    |
      | Name          | Checking |
