Feature: Update a budget
  As a user
  In order to update or correct an existing budget
  I need to be able to update a budget record
  
  Scenario: A user successfully updates a budget
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has a 11-month budget named "2014" starting on 1/1/2014
    
    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Budgets" within the navigation
    
    When I click on "Budgets" within the navigation
    Then I should see "Budgets" within the page title
    And I should see the following budgets table
      | Name | Start date | End date   |
      | 2014 | 1/1/2014   | 11/30/2014 |
    
    When I click the edit button within the budget row for "2014"
    Then I should see "Edit budget" within the page title
    
    When I fill in "Period count" with "12"
    And I click "Save"
    Then I should see "The budget was updated successfully." within the notice area
    And I should see the following budget attributes
      | Name         | 2014       |
      | Period       | month      |
      | Period count | 12         |
      | Start date   | 1/1/2014   |
      | End date     | 12/31/2014 |
     
    When I click "Back"
    Then I should see the following budgets table
      | Name | Start date | End date   |
      | 2014 | 1/1/2014   | 12/31/2014 |
