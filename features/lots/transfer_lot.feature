Feature: Transfer an equity lot
  As a user
  In order to keep my records up to date with my accounts
  I need to be able to transfer an equity lot from one account to another

  Scenario: A user transfer an equity lot
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following accounts
      | Name             | Account type | Content type  |
      | Opening balances | equity       | currency      |
      | IRA              | asset        | commodities   |
      | 401k             | asset        | commodities   |

    And entity "Personal" has the following transactions
      | Transaction date | Description | Amount | Debit account | Credit account   |
      | 2015-01-01       | Opening     |  2,000 | 401k          | Opening balances |

    And entity "Personal" has the following commodities
      | Name                     | Symbol | Market |
      | Knight Software Services | KSS    | NYSE   |

    And account "401k" has the following commodity transactions
      | Date       | Action | Symbol | Shares | Value |
      | 2015-01-02 | buy    | KSS    | 100    | 1,000 |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Accounts" within the navigation

    When I click "Accounts" within the navigation
    Then I should see "Accounts" within the page title
    And I should see the following accounts table
      | Name             |  Balance |
      | Assets           | 2,000.00 |
      | 401k             | 2,000.00 |
      | IRA              |     0.00 |
      | Liabilities      |     0.00 |
      | Equity           | 2,000.00 |
      | Opening balances | 2,000.00 |
      | Income           |     0.00 |
      | Expense          |     0.00 |

    When I click "401k" within the accounts table
    Then I should see "401k Holdings" within the page title
    And I should see the following holdings table
      | Symbol          |    Value |   Shares |     Cost | Gain/Loss |
      | KSS             | 1,000.00 | 100.0000 | 1,000.00 |      0.00 |
      | Commodity total | 1,000.00 |          |          |           |
      | Cash            | 1,000.00 |          |          |           |
      | Total value     | 2,000.00 |          | 1,000.00 |      0.00 |

    When I click "KSS" within the holdings table
    Then I should see "KSS Lots in 401k" within the page title
    And I should see the following lots table
      | Purchase date | Shares owned |     Cost | Current value | Gain/loss |
      |      1/2/2015 |     100.0000 | 1,000.00 |      1,000.00 |      0.00 |

    When I click the transfer button within the 1st lots row
    Then I should see "Transfer lot" within the page title

    When I select "IRA" from the "Target account" list
    And I click "Save"
    Then I should see "The lot was transferred successfully." within the notice area

    When I click "Back"
    And I click "Back"
    Then I should see the following accounts table
      | Name             |  Balance |
      | Assets           | 2,000.00 |
      | 401k             | 1,000.00 |
      | IRA              | 1,000.00 |
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
      | Cash            |     0.00 |          |          |           |
      | Total value     | 1,000.00 |          | 1,000.00 |      0.00 |

    When I click "KSS" within the holdings table
    Then I should see "KSS Lots in IRA" within the page title
    And I should see the following lots table
      | Purchase date | Shares owned |     Cost | Current value | Gain/loss |
      |      1/2/2015 |     100.0000 | 1,000.00 |      1,000.00 |      0.00 |

    When I click "Back"
    And I click "Back"
    Then I should see "Accounts" within the page title

    When I click "401k" within the accounts table
    Then I should see the following holdings table
      | Symbol          |    Value |   Shares |     Cost | Gain/Loss |
      | Commodity total |     0.00 |          |          |           |
      | Cash            | 1,000.00 |          |          |           |
      | Total value     | 1,000.00 |          |     0.00 |      0.00 |
