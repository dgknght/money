Feature: Income statement report
  As a user
  In order to visualize my cash flow for a given period of time
  I need to be able to view an income statement report
  
  Scenario: A user views the income statement report for a past date
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    
    And entity "Personal" has an asset account named "Checking"
    And entity "Personal" has an asset account named "Savings/Car"
    And entity "Personal" has an asset account named "Savings/Reserve"
    And entity "Personal" has an asset account named "House"

    And entity "Personal" has a liability account named "Home Loan"
    And entity "Personal" has a liability account named "Credit Card"
    
    And entity "Personal" has an equity account named "Opening Balances"
    
    And entity "Personal" has an income account named "Salary"
    And entity "Personal" has an income account named "Gifts"
    
    And entity "Personal" has an expense account named "Groceries"
    And entity "Personal" has an expense account named "Mortgage Interest"

    And entity "Personal" has the following transactions
      | Transaction date | Description | Amount   | Credit account    | Debit account     |
      | 2012-12-31       | Open        |  200,000 | Opening Balances  | House             |
      | 2012-12-31       | Open        |  175,000 | Home Loan         | Opening Balances  |
      | 2012-12-31       | Open        |   10,000 | Opening Balances  | Car               |
      | 2012-12-31       | Open        |   30,000 | Opening Balances  | Reserve           |
      | 2013-01-01       | Paycheck    |    5,000 | Salary            | Checking          |
      | 2013-01-01       | Bank        |      900 | Checking          | Mortgage Interest |
      | 2013-01-01       | Bank        |      100 | Checking          | Home Loan         |
      | 2013-01-06       | Kroger      |       80 | Credit Card       | Groceries         |
      | 2013-01-13       | Kroger      |       80 | Credit Card       | Groceries         |
      | 2013-01-15       | Paycheck    |    5,000 | Salary            | Checking          |
      | 2013-01-20       | Kroger      |       80 | Credit Card       | Groceries         |
      | 2013-01-27       | Kroger      |       80 | Credit Card       | Groceries         |
      | 2013-01-31       | Myself      |      350 | Checking          | Car               |
      | 2013-02-01       | Paycheck    |    5,000 | Salary            | Checking          |
      | 2013-02-01       | Bank        |      895 | Checking          | Mortgage Interest |
      | 2013-02-01       | Bank        |      105 | Checking          | Home Loan         |
      | 2013-02-03       | Kroger      |       80 | Credit Card       | Groceries         |
      | 2013-02-07       | Citibank    |      320 | Checking          | Credit Card       |

    And I am signed in as "john@doe.com/please01"

    When I am on the "Personal" entity page
    Then I should see "Reports" within the navigation

    When I click on "Reports" within the navigation
    Then I should see "Reports" within the page title
    And I should see "Income Statement" within the main content

    When I click on "Income Statement" within the main content
    And I fill in "From" with "1/1/2013"
    And I fill in "To" with "1/31/2013"
    And I click "Show"
    
    Then I should see the following accounts table
      | Account           | Balance   |
      | Income            | 10,000.00 |
      | Gifts             |      0.00 |
      | Salary            | 10,000.00 |
      | Expense           |  1,220.00 |
      | Groceries         |    320.00 |
      | Mortgage Interest |    900.00 |
      | Net               |  8,780.00 |
