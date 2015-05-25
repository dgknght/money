Feature: Import from gnucash
  As a user
  In order to migrate from GnuCash
  I need to be able to import a GnuCash XML file

  Scenario: A user imports a gzipped GnuCash file
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"

    When I am signed in as "john@doe.com/please01"
    And I am on the entities page

    When I click "Add" within the main content
    Then I should see "New entity" within the page title

    When I specify the file "sample.gnucash" for "Data"
    And I fill in "Name" with "Imported"
    And I click "Save"
    Then I should see "Entity" within the page title
    And I should see the following accounts table
      | Name                  |    Balance |
      | Assets                | 249,639.51 |
      | Current Assets        |   2,688.00 |
      | Checking              |   2,688.00 |
      | Fixed Assets          | 225,000.00 |
      | House                 | 200,000.00 |
      | Vehicle               |  25,000.00 |
      | Imbalance-USD         |       0.00 |
      | Investments           |  21,951.51 |
      | 401k                  |  21,951.51 |
      | AAPL                  |  12,424.51 |
      | VTSAX                 |   5,228.00 |
      | Liabilities           |  24,400.00 |
      | Loans                 |  24,400.00 |
      | Vehicle Loan          |  24,400.00 |
      | Equity                | 225,239.51 |
      | Opening Balances      | 220,000.00 |
      | Unrealized gains      |   1,961.51 |
      | Retained earnings     |   3,278.00 |
      | Income                |   8,000.00 |
      | Salary                |   8,000.00 |
      | Expense               |   4,722.00 |
      | Groceries             |     800.00 |
      | Interest              |     100.00 |
      | Vehicle Loan Interest |     100.00 |
      | Investment Expenses   |      10.00 |
      | Rent                  |   1,600.00 |
      | Taxes                 |   2,212.00 |
      | Federal Income        |   1,600.00 |
      | Medicare              |     116.00 |
      | Social Security       |     496.00 |
