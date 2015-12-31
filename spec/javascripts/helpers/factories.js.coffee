DEFAULT_ACCOUNT_ATTRIBUTES =
  account_type: 'asset'
  content_type: 'currency'
  balance: 0
  children_balance: 0
  value: 0
  children_value: 0
  cost: 0
  children_cost: 0
  gains: 0
  children_gains: 0
accountFactory = (attributes) ->
  _.extend(DEFAULT_ACCOUNT_ATTRIBUTES, attributes)

