Feature: Delete a budget
  As a user
  In order to remove a budget that I no longer need
  I need to be able to delete a budget record
  
  Scenario: A user deletes a budget
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has a 12-month budget named "2011" starting on 1/1/2011
    And entity "Personal" has a 12-month budget named "2012" starting on 1/1/2012
    
    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Budgets" within the navigation
    
    When I click "Budgets" within the navigation
    Then I should see "Budgets" within the page title
    And I should see the following budgets table
      | Name | Start date | End date   |
      | 2011 | 1/1/2011   | 12/31/2011 |
      | 2012 | 1/1/2012   | 12/31/2012 |
    
    When I click "Delete" within the budget row for "2011"
    Then I should see "The budget was removed successfully." within the notice area.
    And I should see the following budgets table
      | Name | Start date | End date   |
      | 2012 | 1/1/2012   | 12/31/2012 |