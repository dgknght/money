@wip
Feature: Import transactions
  As a user
  In order to use data that I have entered into another accounting system
  I need to be able to import transactions from that system

  Scenario: A user imports transactions from GnuCash
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following accounts
     | Name                   | Account type | Parent    |
     | Checking               | Asset        |           |
     | Savings                | Asset        |           |
     | 401k                   | Asset        |           |
     | Individual             | Asset        |           |
     | Credit card            | Liability    |           |
     | Salary                 | Income       |           |
     | Divident               | Income       |           |
     | 401k employer matching | Income       |           |
     | Rent                   | Expense      |           |
     | Groceries              | Expense      |           |
     | Taxes                  | Expense      |           |
     | Federal                | Expense      | Taxes     |
     | Social Security        | Expense      | Taxes     |
     | Medicare               | Expense      | Taxes     |
     | Insurance              | Expense      |           |
     | Health Insurance       | Expense      | Insurance |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Import" within the navigation

    When I click "Import" within the navigation
    Then I should see "Import transactions" within the main content

    When I click "Import transactions" within the main content
    Then I should see "Import transactions" within the page title

    When I specify the file "transactions.csv" for "Data"
    And I click "Submit"
    Then I should see "Transactions" within the page title
    And I should see the following transactions table
     | Transaction date | Description  |   Amount |
     | 9/5/2014         | LivingSocial | 5,000.00 |
