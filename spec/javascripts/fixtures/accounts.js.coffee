window.CHECKING_ID = 1
window.SALARY_ID = 2
window.GROCERIES_ID = 3
window.RENT_ID = 4
window.DINING_ID = 5

window.ACCOUNTS = [
  accountFactory
    id: CHECKING_ID
    name: 'Checking'
,
  accountFactory
    id: SALARY_ID
    name: 'Salary'
    account_type: 'income'
,
  accountFactory
    id: GROCERIES_ID
    name: 'Groceries'
    account_type: 'expense'
,
  accountFactory
    id: DINING_ID
    name: 'Dining'
    account_type: 'expense'
,
  accountFactory
    id: RENT_ID
    name: 'Rent'
    account_type: 'expense'
]
