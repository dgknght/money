Feature: Import accounts
  As a user
  In order to use data from another accounting application
  I need to be able to import the accounts

  @wip
  Scenario: A user with no existing accounts imports accounts from a GnuCash CSV file
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Import" within the navigation

    When I click "Import Accounts" within the navigation
    Then I should see "Import" within the page title

    When I select "accounts.csv" for "File"
    And I click "Submit"
    Then I should see "Import Accounts" within the page title
    And I should see the following accounts table
      | Name             | Balance |
      | Assets           |    0.00 |
      | Current Assets   |    0.00 |
      | Cash             |    0.00 |
      | Checking         |    0.00 |
      | Savings          |    0.00 |
      | Car              |    0.00 |
      | Fixed Assets     |    0.00 |
      | Home             |    0.00 |
      | Car              |    0.00 |
      | Liability        |    0.00 |
      | Credit Card      |    0.00 |
      | Loans            |    0.00 |
      | Car              |    0.00 |
      | Mortgage         |    0.00 |
      | Equity           |    0.00 |
      | Annual           |    0.00 |
      | Opening Balances |    0.00 |
      | Income           |    0.00 |
      | Bonus            |    0.00 |
      | Gifts            |    0.00 |
      | Salary           |    0.00 |
      | Expense          |    0.00 |
      | Auto             |    0.00 |
      | Gas              |    0.00 |
      | Groceries        |    0.00 |
      | Telephone        |    0.00 |
      | Utilities        |    0.00 |
      | Electric         |    0.00 |
      | Gas              |    0.00 |
