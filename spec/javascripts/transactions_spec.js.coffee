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

      $scope.formTransaction =
        id: _.uniqueInt()
        description: 'Payckeck'
        transaction_date: '2015-01-01'
        items: [
          id: _.uniqueInt()
          action: 'debit'
          account_id: CHECKING_ID
          amount: 1000
        ,
          id: _.uniqueInt()
          action: 'credit'
          account_ID: SALARY_ID
          amount: 1100
        ]

      $scope.formTransaction.transaction_date = '2015-01-02'
      _.each($scope.formTransaction.items, (i) -> i.amount = 1001)
      controller.update()
      expect($httpBackend.flush).not.toThrow()

  describe '$scope.transactionTotals', ->
    beforeEach ->
      $scope.formTransaction =
        description: 'Payckeck'
        transaction_date: '2015-01-01'
        items: [
          action: 'debit'
          account_id: CHECKING_ID
          amount: 1000
        ,
          action: 'credit'
          account_ID: SALARY_ID
          amount: 1100
        ]
      $scope.$digest()
    it 'contains the credit total for the transaction', ->
      expect($scope.transactionTotals.credits).toBe 1100
    it 'contains the debit total for the transaction', ->
      expect($scope.transactionTotals.debits).toBe 1000
    it 'contains the difference between the credit and debit totals', ->
      expect($scope.transactionTotals.difference).toBe -100
  return

describe 'PurchasesController', ->
  controller = {}
  $scope = {}
  $httpBackend = {}

  beforeEach ->
    module 'moneyApp'
    inject ($rootScope, $controller, _$httpBackend_) ->
      $httpBackend = _$httpBackend_
      $httpBackend.expectPOST('/entities/1/transactions.json', (data) ->
        obj = JSON.parse(data)
        trans = obj.transaction
        trans.transaction_date == '1/1/2016' &&
          trans.description == 'Taverna Rossa' &&
          trans.items_attributes.length == 2
      ).respond
        id: _.uniqueInt()
        description: 'Taverna Rossa'
        transaction_date: '2016-01-01'
        items: [
          id: _.uniqueInt()
          action: 'debit'
          account_id: DINING_ID
          amount: 60
        ,
          id: _.uniqueInt()
          action: 'credit'
          account_id: CHECKING_ID
          amount: 60
        ]
      $scope = $rootScope.$new()
      $scope.currentEntityId = 1
      controller = $controller 'PurchasesController', { $scope: $scope }
  describe 'openCalendar', ->
    it 'sets calendarIsOpen to true', ->
      controller.openCalendar()
      expect(controller.calendarIsOpen).toBe true
    return

  setupPurchase = () ->
    controller.newPurchase.transactionDate = '1/1/2016'
    controller.newPurchase.location = 'Taverna Rossa'
    controller.newPurchase.method = CHECKING_ID
    controller.newPurchase.category = DINING_ID
    controller.amount = 60
    return

  describe 'save', ->
    it 'sends a POST message to the service to create the transaction', ->
      setupPurchase()
      controller.save
        $setPristine: _.noop
        $setUntouched: _.noop
      expect($httpBackend.flush).not.toThrow()
    it 'adds the transaction to enteredPurchases', ->
      setupPurchase()
      controller.save
        $setPristine: _.noop
        $setUntouched: _.noop
      $httpBackend.flush()
      expect(_.map(controller.enteredPurchases, (p) -> p.location)).toEqual ["Taverna Rossa"]
    it 'resets the form', ->
      setupPurchase()
      form =
        $setPristine: _.noop
        $setUntouched: _.noop
      _.each ['$setPristine', '$setUntouched'], (m) -> spyOn form, m
      controller.save form
      $httpBackend.flush()
      expect(controller.newPurchase).toEqual
        transactionDate: '1/1/2016'
        method: CHECKING_ID
      expect(form.$setPristine).toHaveBeenCalled()
      expect(form.$setUntouched).toHaveBeenCalled()
    return

