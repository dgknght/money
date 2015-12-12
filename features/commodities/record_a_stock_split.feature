Feature: Record a stock split
  As a user,
  In order to update the value of my stock holdings,
  I need to be able to record a stock split

  Scenario: A user enters a stock split
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following accounts
     | Name             | Account type | Content type |
     | IRA              | asset        | commodities  |
     | Opening balances | equity       | currency     |

   And entity "Personal" has the following transactions
    | Transaction date | Description     | Amount | Credit account   | Debit account |
    |       2015-01-01 | Opening balance | 10,000 | Opening balances | IRA           |

  And entity "Personal" has the following commodities
    | Name                     | Symbol | Market |
    | Knight Software Services | KSS    | NYSE   |

  And account "IRA" has the following commodity transactions
   |       Date | Action | Symbol | Shares | Value |
   | 2015-01-02 |    buy |    KSS |    100 | 2,000 |

  When I am signed in as "john@doe.com/please01"
  And I am on the "Personal" entity page
  Then I should see "Accounts" within the navigation

  When I click "Accounts" within the navigation
  Then I should see the following accounts table
    | Name             |   Balance |
    | Assets           | 10,000.00 |
    | IRA              | 10,000.00 |
    | Liabilities      |      0.00 |
    | Equity           | 10,000.00 |
    | Opening balances | 10,000.00 |
    | Income           |      0.00 |
    | Expense          |      0.00 |

  When I click "IRA" within the accounts table
  Then I should see "IRA Holdings" within the page title
  And I should see the following holdings table
    | Symbol          |     Value |      Shares |     Cost | Gain/Loss |
    | KSS             |  2,000.00 |    100.0000 | 2,000.00 |      0.00 |
    | Commodity total |  2,000.00 |             |          |           |
    | Cash            |  8,000.00 |             |          |           |
    | Total value     | 10,000.00 |             | 2,000.00 |      0.00 |

  When I click "KSS" within the main content
  Then I should see "KSS Lots in IRA" within the page title
  And I should see the following lots table
   | Purchase date | Shares owned |   Price |     Cost | Current value | Gain/loss |
   |      1/2/2015 |     100.0000 | 20.0000 | 2,000.00 |      2,000.00 |      0.00 |

 When I click the split button within the 1st lot row
 Then I should see "KSS Split" within the page title

 When I fill in "Numerator" with "2"
 And I fill in "Denominator" with "1"
 And I click "Save"
 Then I should see "The stock split was recorded successfully" within the notice area
 And I should see the following lots table
   | Purchase date | Shares owned |   Price |     Cost | Current value | Gain/loss |
   |      1/2/2015 |     200.0000 | 10.0000 | 2,000.00 |      2,000.00 |      0.00 |
