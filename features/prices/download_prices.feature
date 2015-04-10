Feature: Download prices
  As a user,
  In order to track that value of my investments,
  I should be able to download price history from the internet

  Scenario: A user gets the latest price from for a commodity
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following accounts
      | Name             | Account type | Content type |
      | 401k             | asset        | commodities  |
      | Opening balances | equity       | currency     |

    And entity "Personal" has the following transactions
      | Transaction date | Description     | Amount | Debit account | Credit account   |
      |       2014-01-01 | Opening balance |  5,000 | 401k          | Opening balances |

    And entity "Personal" has the following commodities
      | Name                     | Symbol | Market |
      | Knight Software Services | KSS    | NYSE   |
      | Apple, Inc.              | AAPL   | NASDAQ |

    And commodity "KSS" has the following online price history
      | Trade date | Price |
      | 2013-12-30 |  9.50 |
      | 2014-01-01 | 10.00 |
      | 2014-01-02 | 10.75 |

    And commodity "AAPL" has the following online price history
      | Trade date | Price |
      | 2013-12-30 | 30.57 |
      | 2014-01-01 | 30.00 |
      | 2014-01-02 | 28.45 |

    And account "401k" has the following commodity transactions
      | Transaction date | Symbol | Action | Shares | Value |
      |       2014-01-02 | KSS    | buy    |    100 |  1000 |
      |       2014-01-02 | AAPL   | buy    |    100 |  3000 |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Accounts" within the navigation

    When I click "Accounts" within the navigation
    Then I should see "Accounts" within the page title
    And I should see the following accounts table
      | Name             |  Balance |
      | Assets           | 5,000.00 |
      | 401k             | 5,000.00 |
      | AAPL             | 3,000.00 |
      | KSS              | 1,000.00 |
      | Liabilities      |     0.00 |
      | Equity           | 5,000.00 |
      | Opening balances | 5,000.00 |
      | Income           |     0.00 |
      | Expense          |     0.00 |

    When I click "Commodities" within the navigation
    Then I should see the following commodities table
      | Name                     | Symbol | Market | Most recent price |
      | Apple, Inc.              | AAPL   | NASDAQ |          30.0000  |
      | Knight Software Services | KSS    | NYSE   |          10.0000  |

    When I click "Download prices"
    Then I should see the following commodities table
      | Name                     | Symbol | Market | Most recent price |
      | Apple, Inc.              | AAPL   | NASDAQ |           28.4500 |
      | Knight Software Services | KSS    | NYSE   |           10.7500 |

    When I click on "Accounts" within the navigation
    Then I should see the following accounts table
      | Name             |  Balance |
      | Assets           | 4,920.00 |
      | 401k             | 4,920.00 |
      | AAPL             | 2,845.00 |
      | KSS              | 1,075.00 |
      | Liabilities      |     0.00 |
      | Equity           | 4,920.00 |
      | Opening balances | 5,000.00 |
      | Unrealized gains |   -80.00 |
      | Income           |     0.00 |
      | Expense          |     0.00 |
