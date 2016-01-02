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

        console.log data

        obj = JSON.parse data

        console.log obj

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
          }
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
    it 'sends a PUT message to the service to update the transaction'

  describe '$scope.transactionTotals', ->
    it 'contains the credit total for the transaction'
    it 'contains the debit total for the transaction'
    it 'contains the difference between the credit and debit totals'
  return
