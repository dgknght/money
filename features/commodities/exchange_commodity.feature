Feature: Exchange commodity shares
  As a user,
  In order to track my investments,
  I need to be able to record an exchange of commodity shares

  Scenario: A user exchanges shares of one commodity for another
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following accounts
      | Name             | Account type | Content type |
      | Opening balances | equity       | currency     |
      | IRA              | asset        | commodities  |

    And entity "Personal" has the following commodities
      | Name                     | Symbol | Market |
      | Knight Software Services | KSS    | NYSE   |
      | Knight Software Empire   | KSE    | NYSE   |

    And entity "Personal" has the following transactions
      | Transaction date | Description     | Amount | Debit account | Credit account   |
      | 2015-01-01       | Opening balance |  2,000 | IRA           | Opening balances |

    And account "IRA" has the following commodity transactions
      |       Date | Action | Symbol | Shares | Value |
      | 2015-01-02 | buy    | KSS    |    100 | 1,000 |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Accounts" within the navigation

    When I click "Accounts" within the navigation
    Then I should see "Accounts" within the page title
    And I should see the following accounts table
      | Name             |  Balance |
      | Assets           | 2,000.00 |
      | IRA              | 2,000.00 |
      | Liabilities      |     0.00 |
      | Equity           | 2,000.00 |
      | Opening balances | 2,000.00 |
      | Income           |     0.00 |
      | Expense          |     0.00 |

    When I click "IRA" within the accounts table
    Then I should see "IRA Holdings" within the page title
    And I should see the following holdings table
      | Symbol          |    Value |   Shares |     Cost | Gain/Loss |
      | KSS             | 1,000.00 | 100.0000 | 1,000.00 |      0.00 |
      | Commodity total | 1,000.00 |          |          |           |
      | Cash            | 1,000.00 |          |          |           |
      | Total value     | 2,000.00 |          | 1,000.00 |      0.00 |

    When I click "KSS" within the holdings table
    Then I should see "KSS Lots in IRA" within the page title
    And I should see the following lots table
      | Purchase date | Shares owned |     Cost | Current value | Gain/loss |
      |      1/2/2015 |     100.0000 | 1,000.00 |      1,000.00 |      0.00 |

    When I click the exchange button within the 1st lots row
    Then I should see "Exchange lot" within the page title

    When I select "KSE" from the "Commodity" list
    And I click "Save"
    Then I should see "The lot was exchanged successfully." within the notice area

    When I click "Back"
    And I click "Back"
    Then I should see the following accounts table
      | Name             |  Balance |
      | Assets           | 2,000.00 |
      | IRA              | 2,000.00 |
      | Liabilities      |     0.00 |
      | Equity           | 2,000.00 |
      | Opening balances | 2,000.00 |
      | Income           |     0.00 |
      | Expense          |     0.00 |

