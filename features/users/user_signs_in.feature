Feature: User sign-in
  @wip
  Scenario: An existing user signs in 
    Given there is a user with email address "john@doe.com" and password "please01"
    And I am on the home page
    When I fill in "Email" with "john@doe.com"
    And I fill in "Password" with "please"
    And I click "Sign In"
    Then I should see "You have been signed in successfully." within the flash success notification area