Feature: Add a budget line item
  As a user
  In order to specify how much money should be spent or received for a given account in a budget time period
  I need to be able to add a line item to a budget

  Background:
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
    Then I should see "2014 budget items" within the page title
    
  Scenario: A user adds a monthly average line item to a budget
    When I click "By average"
    Then I should see "New 2014 budget item" within the page title
    
    And I select "Groceries" from the "Account" list
    And I fill in "Monthly amount" with "350"
    And I click "Save"
    Then  I should see the following budget items table
      | Account   | Jan 2014 | Feb 2014 | Mar 2014 | Apr 2014 | May 2014 | Jun 2014 | Jul 2014 | Aug 2014 | Sep 2014 | Oct 2014 | Nov 2014 | Dec 2014 |     Total |
      | Income    |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |      0.00 |
      | Expense   |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 | -4,200.00 |
      | Groceries |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 | -4,200.00 |
      | Total     |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 | -4,200.00 |
  
  Scenario: A user adds a annual total line item to a budget
    When I click "By total"
    Then I should see "New 2014 budget item" within the page title
    
    And I select "Groceries" from the "Account" list
    And I fill in "Total" with "4200"
    And I click "Save"
    Then  I should see the following budget items table
      | Account   | Jan 2014 | Feb 2014 | Mar 2014 | Apr 2014 | May 2014 | Jun 2014 | Jul 2014 | Aug 2014 | Sep 2014 | Oct 2014 | Nov 2014 | Dec 2014 |     Total |
      | Income    |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |      0.00 |
      | Expense   |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 | -4,200.00 |
      | Groceries |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 | -4,200.00 |
      | Total     |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 |  -350.00 | -4,200.00 |
  
  Scenario: A user adds a month-by-month line item to a budget
    When I click "With detail"
    Then I should see "New 2014 budget item" within the page title
    
    And I select "Groceries" from the "Account" list
    And I fill in "Jan 2014" with "100"
    And I fill in "Feb 2014" with "110"
    And I fill in "Mar 2014" with "120"
    And I fill in "Apr 2014" with "130"
    And I fill in "May 2014" with "140"
    And I fill in "Jun 2014" with "150"
    And I fill in "Jul 2014" with "160"
    And I fill in "Aug 2014" with "170"
    And I fill in "Sep 2014" with "180"
    And I fill in "Oct 2014" with "190"
    And I fill in "Nov 2014" with "200"
    And I fill in "Dec 2014" with "210"
    And I click "Save"
    
    Then  I should see the following budget items table
      | Account   | Jan 2014 | Feb 2014 | Mar 2014 | Apr 2014 | May 2014 | Jun 2014 | Jul 2014 | Aug 2014 | Sep 2014 | Oct 2014 | Nov 2014 | Dec 2014 |     Total |
      | Income    |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |      0.00 |
      | Expense   |  -100.00 |  -110.00 |  -120.00 |  -130.00 |  -140.00 |  -150.00 |  -160.00 |  -170.00 |  -180.00 |  -190.00 |  -200.00 |  -210.00 | -1,860.00 |
      | Groceries |  -100.00 |  -110.00 |  -120.00 |  -130.00 |  -140.00 |  -150.00 |  -160.00 |  -170.00 |  -180.00 |  -190.00 |  -200.00 |  -210.00 | -1,860.00 |
      | Total     |  -100.00 |  -110.00 |  -120.00 |  -130.00 |  -140.00 |  -150.00 |  -160.00 |  -170.00 |  -180.00 |  -190.00 |  -200.00 |  -210.00 | -1,860.00 |
