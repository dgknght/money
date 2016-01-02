describe 'TransactionFormController', ->
  beforeEach module('moneyApp')

  controller = {}
  $scope = {}
  $httpBackend = {}
  $uibModalInstance =
    close: -> return
    dismiss: (reason) -> return

  beforeEach inject( ($controller, $rootScope, _$httpBackend_) ->
    $httpBackend = _$httpBackend_

    $scope = $rootScope.$new()
    $scope.currentEntityId = 1
    controller = $controller 'TransactionFormController', { $scope: $scope, $uibModalInstance: $uibModalInstance }
  )

  describe 'create', ->
    it 'sends a POST message to the service to create the transaction', ->
      $httpBackend.expectPOST('/entities/1/transactions.json', (data) ->
        obj = JSON.parse data
        trans = obj.transaction
        trans.transaction_date == '2015-02-27' &&
          trans.items_attributes.length == 2
      ).respond(
        id: 99
        transaction_date: '2015-02-27'
        description: 'Market Street'
        items: [
          {
            id: 101
            action: 'credit'
            account_id: CHECKING_ID
            amount: 88
          },
          {
            id: 102
            action: 'debit'
            account_id: GROCERIES_ID
            amount: 88
          },
          {}
        ]
      )
      $scope.formTransaction =
        transaction_date: '2015-02-27'
        description: 'Market Street'
        items: [
          {
            action: 'credit'
            account_id: CHECKING_ID
            amount: 88
          },
          {
            action: 'debit'
            account_id: GROCERIES_ID
            amount: 88
          }
        ]
      controller.create()
      expect($httpBackend.flush).not.toThrow()

  describe 'update', ->
    it 'sends a PUT message to the service to update the transaction', ->
      $httpBackend.expectPUT('/transactions/1.json', (data) ->
        obj = JSON.parse(data)
        trans = obj.transaction
        trans.transaction_date = '2015-01-02' &&
          trans.items_attributes[0].amount == 1001
      ).respond("")

      $scope.formTransaction = TRANSACTIONS[0]
      $scope.formTransaction.transaction_date = '2015-01-02'
      _.each($scope.formTransaction.items, (i) -> i.amount = 1001)
      controller.update()
      expect($httpBackend.flush).not.toThrow()

  describe '$scope.transactionTotals', ->
    beforeEach ->
      $scope.formTransaction = TRANSACTIONS[0]
      item = _.find($scope.formTransaction.items, (i) -> i.action == 'credit')
      item.amount = 1100
      $scope.$digest()
    it 'contains the credit total for the transaction', ->
      expect($scope.transactionTotals.credits).toBe 1100
    it 'contains the debit total for the transaction', ->
      expect($scope.transactionTotals.debits).toBe 1000
    it 'contains the difference between the credit and debit totals', ->
      expect($scope.transactionTotals.difference).toBe -100
  return
