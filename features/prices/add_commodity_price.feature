Feature: Add a commodity price
  As a user,
  In order to track the value of a commodity over time,
  I need to be able to enter a commidity price

  Scenario: A user enters a commodity price
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following commodities
      | Name                     | Symbol | Market |
      | Knight Software Services | KSS    | NYSE   |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page

    When I click "Commodities" within the navigation
    Then I should see "Commodities" within the page title
    And I should see the following commodities table
      | Name                     | Symbol | Recent |
      | Knight Software Services | KSS    |        |

    When I click the prices button within the 1st commodity row
    Then I should see "KSS prices" within the page title
    And I should see the following prices table
      | Date | Price |

    When I click "Add"
    Then I should see "New commodity price" within the page title

    When I fill in "Trade date" with "2014-04-24"
    And I fill in "Price" with "11.34"
    And I click "Save"
    Then I should see "The price was created successfully." within the notice area
    And I should see the following prices table
      | Date | Price   |
      |  4/24/2014 | 11.3400 |

    When I click "Back"
    Then I should see the following commodities table
      | Name                     | Symbol | Recent |
      | Knight Software Services | KSS    |           11.3400 |

  Scenario: A user views the effect of a new price on the value of a commodity holding
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following commodities
      | Name                     | Symbol | Market |
      | Knight Software Services | KSS    | NYSE   |

    And entity "Personal" has the following accounts
      | Account type | Name             | Content type |
      | equity       | Opening Balances | currency     |
      | asset        | 401k             | commodities  |

    And entity "Personal" has the following transactions
      |       Date | Description     | Amount | Debit account | Credit account   |
      | 12/31/2013 | Opening balance |  2,000 |          401k | Opening Balances |

    And account "401k" has the following commodity transactions
      | Date     | Action | Symbol | Shares |    Value |
      | 1/1/2014 | buy    | KSS    |    100 | 1,067.00 |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Accounts" within the navigation

    When I click on "Accounts" within the navigation
    Then I should see the following accounts table
      | Name             |  Balance |
      | Assets           | 2,000.00 |
      | 401k             | 2,000.00 |
      | KSS              | 1,067.00 |
      | Liabilities      |     0.00 |
      | Equity           | 2,000.00 |
      | Opening Balances | 2,000.00 |
      | Income           |     0.00 |
      | Expense          |     0.00 |

    When I click "Commodities" within the navigation
    Then I should see "Commodities" within the page title
    And I should see the following commodities table
      | Name                     | Symbol |   Recent |
      | Knight Software Services | KSS    |  10.6700 |

    When I click the prices button within the commodity row for "KSS"
    Then I should see "KSS prices" within the page title
    And I should see the following prices table
      |     Date |   Price |
      | 1/1/2014 | 10.6700 |

    When I click "Add"
    Then I should see "New commodity price" within the page title

    When I fill in "Trade date" with "3/26/2014"
    And I fill in "Price" with "11.34"
    And I click "Save"
    Then I should see "The price was created successfully." within the notice area
    And I should see the following prices table
      |      Date |   Price |
      | 3/26/2014 | 11.3400 |
      |  1/1/2014 | 10.6700 |

    When I click on "Accounts" within the navigation
    Then I should see the following accounts table
      | Name             |  Balance |
      | Assets           | 2,067.00 |
      | 401k             | 2,067.00 |
      | KSS              | 1,134.00 |
      | Liabilities      |     0.00 |
      | Equity           | 2,067.00 |
      | Opening Balances | 2,000.00 |
      | Unrealized gains |    67.00 |
      | Income           |     0.00 |
      | Expense          |     0.00 |
