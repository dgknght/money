@wip
Feature: Enter a commodity purchase transaction
  As a user,
  In order to track a commodity holding
  I need to be able to enter a commodity purchase

  Scenario: A user enters a commodity purchase
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following accounts
      | Account type | Name             | Content type |
      | equity       | Opening Balances | currency     |
      | asset        | 401k             | commodity    |

    And entity "Personal" has the following transactions
      | Transaction date | Description     | Credit account   | Debit account | Amount   |
      |         1/1/2014 | Opening balance | Opening Balances | 401k          | 5,000.00 |

    And entity "Personal" has the following commodities
      | Name                     | Symbol | Market |
      | Knight Software Services | KSS    | NYSE   |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Accounts" within the navigation

    When I click "Accounts" within the navigation
    Then I should see "Accounts" within the page title

    When I click "401k" within the main content
    Then I should see "401k Holdings" within the page title
    And I should see the following holdings table
      | Symbol          |    Value | Cost | Gain/Loss |
      | Commodity total |     0.00 |      |           |
      | Cash            | 5,000.00 |      |           |
      | Total value     | 5,000.00 | 0.00 |      0.00 |

    When I click "Add"
    Then I should see "New commodity transaction" within the page title

    When I fill in "Transaction date" with "3/26/2014"
    And I select "buy" from the "Action" list
    And I fill in "Symbol" with "KSS"
    And I fill in "Shares" with "100"
    And I fill in "Value" with "1100"
    And I click "Save"

    Then I should see "The transaction was created successfully." within the notice area
    And I should see the following holdings table
      | Symbol          |    Value | Cost | Gain/Loss |
      | KSS             | 1,100.00 | 0.00 |      0.00 |
      | Commodity total | 1,100.00 |      |           |
      | Cash            | 3,900.00 |      |           |
      | Total value     | 5,000.00 | 0.00 |      0.00 |
