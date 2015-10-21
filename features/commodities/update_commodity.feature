Feature: Update a commodity
  As a user,
  In order to keep a commodity up-to-date,
  I need to be able to update the commodity

  Scenario: A user updates a commodity
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has a commodity named "Night Software Services" with symbol "KSS" traded on "NYSE"

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Commodities" within the navigation

    When I click "Commodities" within the navigation
    Then I should see "Commodities" within the page title
    And I should see the following commodities table
      | Name                    | Symbol | Market |
      | Night Software Services | KSS    | NYSE   |

    When I click the edit button within the 1st commodity row
    Then I should see "Edit commodity" within the page title

    When I fill in "Name" with "Knight Software Services"
    And I click "Save"
    Then I should see "The commodity was updated successfully" within the notice area
    And I should see the following commodities table
      | Name                     | Symbol | Market |
      | Knight Software Services | KSS    | NYSE   |
