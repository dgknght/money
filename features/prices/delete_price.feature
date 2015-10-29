Feature: Delete a price
  As a user,
  In order to correct a mistake,
  I need to be able to delete a price

  Scenario: A user deletes a price
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following commodities
      | Name                     | Symbol | Market |
      | Knight Software Services | KSS    | NYSE   |
    And commodity "KSS" has the following prices
      | Trade date |  Price |
      | 2014-01-01 | 7.7777 |
      | 2014-01-02 | 8.8888 |
      | 2014-01-03 | 9.9999 |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Commodities" within the navigation

    When I click "Commodities" within the navigation
    Then I should see "Commodities" within the page title
    And I should see the following commodities table
      | Name                     | Symbol | Market | Recent |
      | Knight Software Services | KSS    | NYSE   | 9.9999 |

    When I click the prices button within the 1st commodity row
    Then I should see "KSS prices" within the page title
    And I should see the following prices table
      |     Date |  Price |
      | 1/3/2014 | 9.9999 |
      | 1/2/2014 | 8.8888 |
      | 1/1/2014 | 7.7777 |

    When I click the delete button within the 1st price row
    Then I should see "The price was deleted successfully." within the notice area
    And I should see the following prices table
      |     Date |  Price |
      | 1/2/2014 | 8.8888 |
      | 1/1/2014 | 7.7777 |

    When I click "Back"
    Then I should see the following commodities table
      | Name                     | Symbol | Market | Recent |
      | Knight Software Services | KSS    | NYSE   | 8.8888 |
