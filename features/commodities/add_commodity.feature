Feature: Add a commodity
  As a user,
  In order to track investments in a commodity,
  I need to be able to enter that commodity into the system

  Scenario:
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Commodities" within the navigation

    When I click "Commodities" within the navigation
    Then I should see "Commodities" within the page title
    And I should see the following commodities table
      | Name | Symbol | Market | Recent |
    
    When I click "Add"
    Then I should see "New commodity" within the page title

    When I fill in "Name" with "Knight Software Services"
    And I fill in "Symbol" with "KSS"
    And I select "NYSE" from the "Market" list
    And I click "Save"

    Then I should see "The commodity was created successfully." within the notice area
    And I should see the following commodities table
      | Name                     | Symbol | Market | Recent |
      | Knight Software Services | KSS    | NYSE   |        |
