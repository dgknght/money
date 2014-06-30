Feature: Add an investment account
  As a user,
  In order to track my investment holdings,
  I need to be able to add an investment account

  Scenario: A user adds an invesment account
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following accounts
      | Account type | Name             | Content type |
      | equity       | Opening Balances | currency     |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Accounts" within the navigation

    When I click "Accounts" within the navigation
    Then I should see "Accounts" within the page title
    And I should see the following accounts table
      | Name             | Balance |
      | Assets           |    0.00 |
      | Liabilities      |    0.00 |
      | Equity           |    0.00 |
      | Opening Balances |    0.00 |
      | Income           |    0.00 |
      | Expense          |    0.00 |

    When I click "Add"
    Then I should see "New account" within the page title

    When I fill in "Name" with "401k"
    And I select "commodities" from the "Content type" list
    And I click "Save"
    Then I should see "The account was successfully created." within the notice area
    And I should see the following accounts table
      | Name             | Balance |
      | Assets           |    0.00 |
      | 401k             |    0.00 |
      | Liabilities      |    0.00 |
      | Equity           |    0.00 |
      | Opening Balances |    0.00 |
      | Income           |    0.00 |
      | Expense          |    0.00 |
