@wip
Feature: View a budget report
  As a user
  In order to compare my actual cash flow with my planned cash flow
  I need to be able to view a budget report
  
  Scenario: A user views a budget report
    Given there is a user with email address "john@doe.com" and password "please01"
    And user "john@doe.com" has an entity named "Personal"
    And entity "Personal" has an asset account named "Checking"
    And entity "Personal" has an income account named "Salary"
    And entity "Personal" has an expense account named "Rent"

    And entity "Personal" has a 12-month budget named "2013" starting on 1/1/2013
    And budget "2013" allocates $5,000 a month for "Salary"
    And budget "2013" allocates $1,200 a month for "Rent"

    And entity "Personal" has the following transactions
      | Transaction date | Description | Amount  | Credit account | Debit account |
      | 2013-01-01       | My employer |  2,500  | Salary         | Checking      |
      | 2013-01-02       | My landlord |  1,200  | Checking       | Rent          |
      | 2013-01-15       | My employer |  2,500  | Salary         | Checking      |
      | 2013-02-01       | My employer |  2,500  | Salary         | Checking      |
      | 2013-02-15       | My landlord |  1,500  | Checking       | Rent          |

    When I am signed in as "john@doe.com/please01"
    And I am on the "Personal" entity page
    Then I should see "Reports" within the navigation

    When I click "Reports" in the navigation
    Then I should see "Budget Report" within the main content

    When I click "Budget Report" within the main content
    Then I should see "Budget Report" within the page title

    When I fill in "Start" with "2013-01-01"
    And I fill in "End" with "2013-02-28"
    And I click "Show"
    Then I should see the following budget report table
      | Account    |    Budget |   Actual  | Difference | % Diff. |    Act/Mo |
      | Income     | 10,000.00 | 7,500.00  |     -2,500 |  -25.0% |  3,750.00 |
      | Salary     | 10,000.00 | 7,500.00  |     -2,500 |  -25.0% |  3,750.00 |
      | Expense    | -2,400.00 | -2,700.00 |    -300.00 |  -12.5% | -1,350.00 |
      | Rent       | -2,400.00 | -2,700.00 |    -300.00 |  -12.5% | -1,350.00 |
      | Net Income | 7,600.00  |  4,800.00 |  -2,800.00 |  -36.8% |  2,400.00 |

