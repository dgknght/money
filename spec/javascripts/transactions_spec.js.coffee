describe 'TransactionsController', ->
  beforeEach module('moneyApp')

  controller = {}
  $scope = {}
  $httpBackend = {}

  beforeEach inject( ($controller, $rootScope, _$httpBackend_) ->
    $httpBackend = _$httpBackend_
    $scope = $rootScope.$new()
    controller = $controller 'TransactionsController', { $scope: $scope }
  )

  describe 'create', ->
    it 'sends a POST message to the service to create the transaction'

  describe 'update', ->
    it 'sends a PUT message to the service to update the transaction'

  describe '$scope.transactionTotals', ->
    it 'contains the credit total for the transaction'
    it 'contains the debit total for the transaction'
    it 'contains the difference between the credit and debit totals'
  return
