Feature: Add an entity
  Scenario: A user adds a new entity
    Given there is a user with email address "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"
    
    When I am on my home page
    
    Then I should see "Entities" within the page title
      
    When I click "Add" within the main content
    Then I should see "New entity" within the page title
    
    When I fill in "Name" with "Personal"
    And I click "Save"
    
    Then I should see "The entity was created successfully." within the notice area
    And I should see the following entity attributes
      | Name     | Personal |
      
    When I click on "Entities" within the navigation
    Then I should see the following entities table
      | Name     |
      | Personal |