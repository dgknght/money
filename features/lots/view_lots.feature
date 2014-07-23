@wip
Feature: View lots
  As a user,
  In order to see a break down of my holdings by purchase,
  I need to be able to see the lots for each holding

  Scenario: A user views lots for their holdings
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following accounts
      | Name                     | Account type | Content type |
      | Opening balances         | equity       | currency     |
      | 401k                     | asset        | commodities  |
      | Long-term capital gains  | income       | currency     |
      | Short-term capital gains | income       | currency     |
    And entity "Personal" has the following transactions
      | Transaction date | Description     | Amount | Debit account | Credit account   |
      |       2014-01-01 | Opening balance | 10,000 | 401k          | Opening balances |
    And entity "Personal" has the following commodities
      | Name                     | Symbol | Market |
      | Knight Software Services | KSS    | NYSE   |
    And account "401k" has the following commodity transactions
      |       Date | Action | Symbol | Shares | Value |
      | 2014-02-01 | buy    | KSS    |    100 |  1000 |
      | 2014-03-01 | buy    | KSS    |    100 |  1200 |
      | 2014-04-01 | sell   | KSS    |     50 |   750 |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Accounts" within the navigation

    When I click "Accounts" within the navigation
    Then I should see "Accounts" within the page title
    And I should see "401k" within the main content

    When I click "401k" within the main content
    Then I should see "401k Holdings" within the page title
    And I should see the following holdings table
      | Symbol          |     Value |      Shares |     Cost | Gain/Loss |
      | KSS             |  2,250.00 |    150.0000 | 1,700.00 |    550.00 |
      | Commodity total |  2,250.00 |             |          |           |
      | Cash            |  8,550.00 |             |          |           |
      | Total value     | 10,800.00 |             | 1,700.00 |    550.00 |

    When I click "KSS" within the main content
    Then I should see "KSS Lots in 401k"
    And I should see the following lots table
      | Purchase date | Shared owned |   Price |    Value |
      | 2/1/2014      |           50 | 10.0000 |   500.00 |
      | 3/1/2014      |          100 | 12.0000 | 1,200.00 |
