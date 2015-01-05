Feature: Add a budget monitor
  As a user
  In order to see up-to-the-day budget progress
  I want to be able to select an account for a budget monitor

  Scenario: A user selects an account for a budget monitor
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has the following accounts
      | Name     | Account type | 
      | Salary   | income       |
      | Checking | asset        |
      | Dining   | expense      |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Budget monitors" within the navigation

    When I click "Budget monitors" within the navigation
    Then I should not see "Dining" within the budget monitors area

    When I click "Add" within the budget monitors area
    Then I should see "New Budget monitor" within the page title

    When I select "Dining" from the "Account" list
    And I click "Save"
    Then I should see "Dining" within the budget monitors area
