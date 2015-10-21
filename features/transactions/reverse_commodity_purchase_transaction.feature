Feature: Reverse a commodity purchase
  As a user,
  In order to correct a mistake,
  I need to able to reverse a commodity purchase

  Scenario: A user reverses a commodity purchase
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following accounts
      | Name                     | Account type   | Content type |
      | 401k                     | asset          | commodities  |
      | Short-term capital gains | income         | currency     |
      | Long-term capital gains  | income         | currency     |
      | Opening balances         | equity         | currency     |
    And entity "Personal" has the following transactions
      | Transaction date | Description     | Amount | Debit account | Credit account   |
      |       2014-01-01 | Opening balance | 10,000 | 401k          | Opening balances |
    And entity "Personal" has the following commodities
      | Name                     | Symbol | Market |
      | Knight Software Services | KSS    | NYSE   |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "401k" within the main content

    When I click "401k" within the main content
    Then I should see "401k Holdings" within the page title
    And I should see the following holdings table
      | Symbol          | Value     | Cost | Gain/Loss |
      | Commodity total |      0.00 |      |           |
      | Cash            | 10,000.00 |      |           |
      | Total value     | 10,000.00 | 0.00 |      0.00 |

    When I click "Add"
    Then I should see "New commodity transaction" within the page title

    When I fill in "Transaction date" with "2014-01-02"
    And I select "buy" from the "Action" list
    And I fill in "Symbol" with "KSS"
    And I fill in "Shares" with "100"
    And I fill in "Value" with "1000"
    And I click "Save"
    Then I should see "401k Holdings" within the page title
    And I should see the following holdings table
      | Symbol          | Value     | Cost     | Gain/Loss |
      | KSS             |  1,000.00 | 1,000.00 |      0.00 |
      | Commodity total |  1,000.00 |          |           |
      | Cash            |  9,000.00 |          |           |
      | Total value     | 10,000.00 | 1,000.00 |      0.00 |

    When I click "Back"
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

    # Also need to confirm the lot exists, and then is destroyed later

    When I click on "KSS"
    Then I should see "KSS Transaction items" within the page title
    And I should see the following transaction items table
      | Transaction date | Description                               | Account | Rec. |   Amount |  Balance |
      |         1/2/2014 | Purchase 100.0 share(s) of KSS at 10.0000 | 401k    |      | 1,000.00 | 1,000.00 |

    When I click the delete button within the 1st transaction item row
    Then I should see "The commodity transaction was removed successfully." within the notice area
    And I should see the following transaction items table
      | Transaction date | Description                             | Account | Rec. |   Amount |  Balance |

    When I click "Back"
    Then I should see "Accounts" within the page title

    When I click "401k"
    Then I should see "401k Holdings" within the page title
    And I should see the following holdings table
      | Symbol          | Value     | Cost | Gain/Loss |
      | Commodity total |      0.00 |      |           |
      | Cash            | 10,000.00 |      |           |
      | Total value     | 10,000.00 | 0.00 |      0.00 |
