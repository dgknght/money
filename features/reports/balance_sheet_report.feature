@wip
Feature: Balance sheet report
  As a user
  In order to visualize my current balance sheet accounts
  I need to be able to view a balance sheet report
  
  Scenario: A user views the balance sheet report for a past date
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    
    And entity "Personal" has an asset account named "Checking" with a balance of $2,000
    And entity "Personal" has an asset account named "Savings/Car" with a balance of $10,000
    And entity "Personal" has an asset account named "Savings/Reserve" with a balance of $30,000
    And entity "Personal" has an asset account named "House" with a balance of $200,000

    And entity "Personal" has a liability account named "Home Loan" with a balance of $175,000
    And entity "Personal" has a liability account named "Credit Card" with a balance of $2,000
    
    And entity "Personal" has an equity account named "Opening Balances" with a balance of $65,000
    
    And entity "Personal" has an income account named "Salary"
    
    And entity "Personal" has an expense account named "Groceries"
    And entity "Personal" has an expense account named "Mortgage Interest"

    And entity "Personal" has the following transactions
      | Transaction date | Description | Amount | Credit account | Debit account     |
      | 01/01/2013       | Paycheck    |   5000 | Salary         | Checking          |
      | 01/01/2013       | Bank        |    900 | Checking       | Mortgage Interest |
      | 01/01/2013       | Bank        |    100 | Checking       | Home Loan         |
      | 01/06/2013       | Kroger      |     80 | Credit Card    | Groceries         |
      | 01/13/2013       | Kroger      |     80 | Credit Card    | Groceries         |
      | 01/15/2013       | Paycheck    |   5000 | Salary         | Checking          |
      | 01/20/2013       | Kroger      |     80 | Credit Card    | Groceries         |
      | 01/27/2013       | Kroger      |     80 | Credit Card    | Groceries         |
      | 01/31/2013       | Myself      |    350 | Checking       | Car               |
      | 02/01/2013       | Paycheck    |   5000 | Salary         | Checking          |
      | 02/01/2013       | Bank        |    895 | Checking       | Mortgage Interest |
      | 02/01/2013       | Bank        |    105 | Checking       | Home Loan         |
      | 02/03/2013       | Kroger      |     80 | Credit Card    | Groceries         |
      | 02/07/2013       | Citibank    |    320 | Checking       | Credit Card       |

    And I am signed in as "john@doe.com/please01"

    When I am on the "Personal" entity page
    Then I should see "Reports" within the secondary navigation

    When I click on "Reports" within the secondary navigation
    Then I should see "Reports" within the page title
    And I should see "Balance Sheet" within the main content

    When I click on "Balance Sheet" within the main content
    And I fill in "As of" with "1/31/2013"
    And I click "Show"
    Then I should see the following accounts table
      | Name                | Balance        |
      | Assets              |     251,350.00 |
      |   Checking          |    11,000.00   |
      |   House             |   200,000.00   |
      |   Savings           |    40,350.00   |
      |     Car             |  10,350.00     |
      |     Reserve         |  30,000.00     |
      | Liabilities         |     177,000.00 |
      |   Credit Card       |     2,000.00   |
      |   Home Loan         |   175,000.00   |
      | Equity              |           0.00 |
      |   Opening Balances  |    65,000.00   |
      |   Retained Earnings |     9,350.00   |
      