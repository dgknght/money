Feature: Delete an entity
  Scenario: A user deletes an existing entity
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "My stuff"
    And I am signed in as "john@doe.com/please01"
    
    When I am on my home page
    Then I should see the following entities table
      | Name     |
      | My stuff |
      
    When I click "Delete" within the entity row for "My stuff"
    Then I should see "The entity was removed successfully." within the notice area
    And I should see the following entities table
      | Name |