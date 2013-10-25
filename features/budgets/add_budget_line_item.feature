@wip
Feature: Add a budget line item
  As a user
  In order to specify how much money should be spent or received for a given account in a budget time period
  I need to be able to add a line item to a budget
  
  Scenario: A user adds a monthly average line item to a budget
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has an expense account named "Groceries"
    And entity "Personal" has a 12-month budget named "2014" starting on 1/1/2014
    
    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Budgets" within the navigation
    
    When I click "Budgets" within the navigation
    Then I should see "Budgets" within the page title
    And I should see the following budgets table
      | Name | Start date | End date   |
      | 2014 | 1/1/2014   | 12/31/2014 |
    
    When I click "2014" within the budget row for "2014"
    Then I should see "Budget items" within the page title
    
    When I click "Add"
    Then I should see "New budget item" within the page title
    
    When I select "Monthly average" from the "Method" list
    And I select "Groceries" from the "Account" list
    And I fill in "Amount" with "350"
    And I click "Save"
    
    Then I should see "The line item was created successfully." within the notice area
    And I should see the following line item table
      | Account   | Jan 2014 | Feb 2014 | Mar 2014 | Apr 2014 | May 2014 | Jun 2014 | Jul 2014 | Aug 2014 | Sep 2014 | Oct 2014 | Nov 2014 | Dec 2014 |    Total |
      | Income    |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |
      | Expense   |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 | 4,200.00 |
      | Groceries |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 |   350.00 | 4,200.00 |