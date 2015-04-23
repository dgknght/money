@wip
Feature: Record a stock split
  As a user,
  In order to update the value of my stock holdings,
  I need to be able to record a stock split

  Scenario: A user enters a stock split
    Given there is a user with email address "john@doe.com" and password "please"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following accounts
     | Name             | Account type | Content type |
     | IRA              | asset        | commodities  |
     | Opening balances | equity       | currency     |

   And entity "Personal" has the following transactions
    | Transaction date | Amount | Credit account   | Debit account |
    |       2015-01-01 | 10,000 | Opening balances | IRA           |

  And entity "Personal" has the following commodities
    | Name                     | Symbol | Market |
    | Knight Software Services | KSS    | NYSE   |

  And account "IRA" was used to purchase 100 shares of KSS for $1,000 on 1/2/2015

  When I am signed in as "john@doe.com/please"
  And I am on the "Personal" entity page
  Then I should see "Commodities" within the navigation

  When I click "Commodities" within the navigation
  Then I should see the following commodities table
    | Name                     | Symbol | Market |
    | Knight Software Services | KSS    | NYSE   |

  When I click "Lots" within the 1st commodity row
  Then I should see "KSS Lots" within the page title
  And I should see the following lots table
   | Purchase date | Price | Shares owned | Current value |
   |      1/2/2015 | 10.00 |          100 |      1,000.00 |

 When I click "Split" within the 1st lot row
 Then I should see "KSS Split" within the page title

 When I fill in "Numerator" with 2
 And I fill in "Denominator" with 1
 And I click "Save"
 Then I should see "The stock split was recorded successfully" within the notice area
 And I should see the following lots table
   | Purchase date | Price | Shares owned | Current value |
   |      1/2/2015 |  5.00 |          200 |      1,000.00 |
