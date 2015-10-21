Feature: Update a commodity price
  As a user,
  In order to calculate the current value of my holdings in a commodity,
  I need to be update to update a commodity price

  Scenario: A user updates a commodity price
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following commodities
      | Name                     | Symbol | Market |
      | Knight Software Services | KSS    | NYSE   |
    And commodity "KSS" has the following prices
      | Trade date | Price   |
      | 2014-01-01 | 10.0000 |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Commodities" within the navigation

    When I click "Commodities" within the navigation
    Then I should see "Commodities" within the page title
    And I should see the following commodities table
      | Name                     | Symbol | Market | Most recent price |
      | Knight Software Services | KSS    | NYSE   |           10.0000 |

    When I click "Prices" within the 1st commodity row
    Then I should see "Prices" within the page title
    And I should see the following prices table
      | Trade date |   Price |
      |   1/1/2014 | 10.0000 |

    When I click the edit button within the 1st price row
    Then I should see "Edit price" within the page title

    When I fill in "Trade date" with "2014-02-01"
    And I fill in "Price" with "11.1234"
    And I click "Save"
    Then I should see "The price was updated successfully." within the notice area
    And I should see the following prices table
      | Trade date |   Price |
      |   2/1/2014 | 11.1234 |

    When I click "Back"
    Then I should see "Commodities" within the page title
    And I should see the following commodities table
      | Name                     | Symbol | Market | Most recent price |
      | Knight Software Services | KSS    | NYSE   |           11.1234 |

