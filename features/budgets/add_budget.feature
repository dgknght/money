Feature: Add a budget
  As a user
  In order to plan my expenses
  I need to be able to create a budget
  
  Scenario: A user create a budget
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And I am signed in as "john@doe.com/please01"
    When I am on the "Personal" entity page
    Then I should see "Budgets" within the navigation
    
    When I click on "Budgets" within the navigation
    Then I should see "Budgets" within the page title
    
    When I click "Add"
    Then I should see "New budget" within the page title

    When I fill in "Name" with "2014"
    And I fill in "Start" with "1/1/2014"
    And I fill in "Period count" with "12"
    And I select "month" from the "Period" list
    And I click "Save"
    Then I should see the following budgets table
      | Name | Start date | End date   |
      | 2014 | 1/1/2014   | 12/31/2014 |
