Feature: View accounts
  Scenario: A user views their list of accounts
    Given there is a user with email address "john@doe.com" and password "please01"

    And user "john@doe.com" has an asset account named "Checking"
    And user "john@doe.com" has an asset account named "Savings"
    And user "john@doe.com" has an asset account named "Home"
    
    And user "john@doe.com" has a liability account named "Credit Card"
    And user "john@doe.com" has a liability account named "Home Loan"

    And user "john@doe.com" has an equity account named "Retained"
    
    And I am signed in as "john@doe.com/please01"
    And I am on my home page
    Then I should see the following accounts table
      | Name        | Balance |
      | Assets      | 0.00    |
      | Checking    | 0.00    |
      | Savings     | 0.00    |
      | Home        | 0.00    |
      | Liabilities | 0.00    |
      | Credit Card | 0.00    |
      | Home Loan   | 0.00    |
      | Equity      | 0.00    |
      | Retained    | 0.00    |