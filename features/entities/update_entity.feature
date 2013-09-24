Feature: Update an entity
  Scenario: A user updates an existing entity
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "My stuff"
    And I am signed in as "john@doe.com/please01"
    
    When I am on my home page
    Then I should see the following entities table
      | Name     |
      | My stuff |
      
    When I click on "Edit" within the entity row for "My stuff"
    Then I should see "Edit entity" within the page title
    
    When I fill in "Name" with "The new name"
    And I click "Save"
    Then I should see "The entity was updated successfully." within the notice area
    And I should see the following entity attributes
      | Name | The new name |
     
    When I click on "Entities" within the navigation
    Then I should see the following entities table
      | Name         |
      | The new name |
