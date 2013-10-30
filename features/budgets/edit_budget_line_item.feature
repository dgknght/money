@wip
Feature: Edit a budget line item
  As a user
  In order to keep a budget line item up-to-date
  I need to be able to edit the line item record
  
  Scenario: A user updates a budget line item:
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has an expense account named "Groceries"
    And entity "Personal" has a 12-month budget named "2014" starting on 1/1/2014
    And budget "2014" allocates $350.00 a month for "Groceries"
    
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
    And  I should see the following budget items table
      | Account   | Jan 2014 | Feb 2014 | Mar 2014 | Apr 2014 | May 2014 | Jun 2014 | Jul 2014 | Aug 2014 | Sep 2014 | Oct 2014 | Nov 2014 | Dec 2014 |     Total |
      | Income    |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |      0.00 |
      | Expense   |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 | -4,200.00 |
      | Groceries |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 | -4,200.00 |
      | Total     |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 | -4,200.00 |

    When I click on "Edit" within the budget item row for "Groceries"
    Then I should see "Edit budget item" within the page title
    
    When I select "total" from the "Method" list
    And I fill in "Total" with "4000"
    And I click "Save"
    Then I should see "The budget item was updated successfully." within the notice area
    And I should see the following budget item periods table
      | Start date | Budget amount |
      | 1/1/2014   |        333.33 |
      | 2/1/2014   |        333.33 |
      | 3/1/2014   |        333.33 |
      | 4/1/2014   |        333.33 |
      | 5/1/2014   |        333.33 |
      | 6/1/2014   |        333.33 |
      | 7/1/2014   |        333.33 |
      | 8/1/2014   |        333.33 |
      | 9/1/2014   |        333.33 |
      | 10/1/2014  |        333.33 |
      | 11/1/2014  |        333.33 |
      | 12/1/2014  |        333.33 |

    When I click "Back"
    Then I should see "Budget items" within the page title
    And I should see the following budget items table
      | Account   | Jan 2014 | Feb 2014 | Mar 2014 | Apr 2014 | May 2014 | Jun 2014 | Jul 2014 | Aug 2014 | Sep 2014 | Oct 2014 | Nov 2014 | Dec 2014 |     Total |
      | Income    |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |      0.00 |
      | Expense   |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 | -3,999.96 |
      | Groceries |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 | -3,999.96 |
      | Total     |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 |  -333.33 | -3,999.96 |
