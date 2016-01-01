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
window.accountFactory = (attributes) ->
  _.defaults attributes, DEFAULT_ACCOUNT_ATTRIBUTES

window._lastIds = {}
window.nextId = (modelName) ->
  last = _lastIds[modelName] || 0
  result = last + 1
  _lastIds[modelName] = result
  result

window.transactionFactory = (attributes) ->
  result = _.pick(attributes, 'transaction_date', 'description')
  result.id = nextId('transaction')
  result.items = [
    id: nextId('transactionItem')
    action: 'debit'
    account_id: attributes['debitAccountId']
    amount: attributes['amount']
  ,
    id: nextId('transactionItem')
    action: 'credit'
    account_id: attributes['creditAccountId']
    amount: attributes['amount']
  ]
  result
