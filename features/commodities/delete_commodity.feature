Feature: Delete a commodity
  As a user,
  In order to correct a mistake,
  I need to be able to delete a commodity

  Scenario: A user deletes a commodity
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has a commodity named "ACME" with symbol "ACME" traded on "NYSE"

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Commodities" within the navigation

    When I click "Commodities" within the navigation
    Then I should see "Commodities" within the page title
    And I should see the following commodities table
      | Name | Symbol | Market |
      | ACME | ACME   | NYSE   |

    When I click "Delete" within the 1st commodity row
    Then I should see "The commodity was removed successfully" within the notice area
    And I should not see "ACME"
