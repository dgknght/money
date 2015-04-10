Feature: Balance sheet report
  As a user
  In order to visualize my current balance sheet accounts
  I need to be able to view a balance sheet report
  
  Scenario: A user views the balance sheet report for a past date
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
    And I should see "Balance Sheet" within the main content

    When I click on "Balance Sheet" within the main content
    And I fill in "As of" with "1/31/2013"
    And I click "Show"
    Then I should see the following accounts table
      | Account               | Balance        |
      | Assets                |     249,000.00 |
      |   Checking            |     8,650.00   |
      |   House               |   200,000.00   |
      |   Savings             |    40,350.00   |
      |     Car               |  10,350.00     |
      |     Reserve           |  30,000.00     |
      | Liabilities           |     175,220.00 |
      |   Credit Card         |       320.00   |
      |   Home Loan           |   174,900.00   |
      | Equity                |      73,780.00 |
      |   Opening Balances    |    65,000.00   |
      |   Retained Earnings   |     8,780.00   |
      |   Unrealized Gains    |         0.00   |
      | Liabilities + Equity  |     249,000.00 |      
