Feature: Enter a commodity sale transaction
  As a user,
  In order to account for the sale of a commodity,
  I need to be able to enter the sale details into the system

  Scenario: A user enters a commodity sale transaction
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following accounts
      | Name                     | Account type | Content type | 
      | 401k                     | asset        | commodities  |
      | Opening balances         | equity       | currency     |
      | Short-term capital gains | income       | currency     |
      | Long-term capital gains  | income       | currency     |

    And entity "Personal" has the following transactions
      | Transaction date | Description     |    Amount | Debit account | Credit account   |
      | 2014-01-01       | Opening Balance | 10,000.00 | 401k          | Opening balances |

    And entity "Personal" has the following commodities
      | Name                     | Symbol | Market |
      | Knight Software Services | KSS    | NYSE   |

    And account "401k" was used to purchase 100 shares of KSS for $1,000 on 1/2/2014

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Accounts" within the navigation

    When I click "Accounts" within the navigation
    Then I should see "Accounts" within the page title
    And I should see the following accounts table
      | Name                     |   Balance |
      | Assets                   | 10,000.00 |
      | 401k                     | 10,000.00 |
      | KSS                      |  1,000.00 |
      | Liabilities              |      0.00 |
      | Equity                   | 10,000.00 |
      | Opening balances         | 10,000.00 |
      | Income                   |      0.00 |
      | Long-term capital gains  |      0.00 |
      | Short-term capital gains |      0.00 |
      | Expense                  |      0.00 |

    When I click "401k"
    Then I should see "401k Holdings" within the page title
    And I should see the following holdings table
      | Symbol          |     Value |     Cost | Gain/Loss |
      | KSS             |  1,000.00 | 1,000.00 |      0.00 |
      | Commodity total |  1,000.00 |          |           |
      | Cash            |  9,000.00 |          |           |
      | Total value     | 10,000.00 | 1,000.00 |      0.00 |

    When I click "Add"
    Then I should see "New commodity transaction" within the page title

    When I fill in "Transaction date" with "1/15/2014"
    And I select "sell" from the "Action" list
    And I fill in "Symbol" with "KSS"
    And I fill in "Shares" with "50"
    And I fill in "Value" with "600"
    And I click "Save"

    Then I should see "The transaction was created successfully." within the notice area
    And I should see "401k Holdings" within the page title
    And I should see the following holdings table
      | Symbol          |     Value |     Cost | Gain/Loss |
      | KSS             |    600.00 |   500.00 |    100.00 |
      | Commodity total |    600.00 |          |           |
      | Cash            |  9,600.00 |          |           |
      | Total value     | 10,200.00 |   500.00 |    100.00 |

    When I click "Back"
    Then I should see "Accounts" within the page title
    And I should see the following accounts table
      | Name                     |   Balance |
      | Assets                   | 10,200.00 |
      | 401k                     | 10,200.00 |
      | KSS                      |    600.00 |
      | Liabilities              |      0.00 |
      | Equity                   | 10,200.00 |
      | Opening balances         | 10,000.00 |
      | Unrealized gains         |    100.00 |
      | Retained earnings        |    100.00 |
      | Income                   |    100.00 |
      | Long-term capital gains  |      0.00 |
      | Short-term capital gains |    100.00 |
      | Expense                  |      0.00 |

