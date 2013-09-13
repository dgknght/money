Feature: User sign-in
  Scenario: An existing user signs in 
    Given there is a user with email address "john@doe.com" and password "please01"
    And I am on the home page
    Then I should see "Sign in" within the navigation
    
    When I click "Sign in" within the navigation
    Then I should see "Sign in" within the page title
    
    When I fill in "Email" with "john@doe.com"
    And I fill in "Password" with "please01"
    And I click "Sign in" within the main content
    Then I should see "Sign out"
#    Then I should see "You have been signed in successfully." within the success notification area