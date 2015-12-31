describe 'AccountsController', ->
  beforeEach module('moneyApp')

  controller = {}
  $scope = {}
  $httpBackend = {}

  beforeEach inject( ($controller, $rootScope, _$httpBackend_) ->
    $httpBackend = _$httpBackend_
    $httpBackend.whenGET('account-form.html').respond("")
    $httpBackend.when('GET', '/entities.json').respond([
      id: 1
      name: 'Personal'
    ])
    $httpBackend.when('GET', '/entities/1/accounts.json').respond([
      accountFactory(
        id: 1
        name: 'Checking'
      ),
      accountFactory(
        id: 2
        name: 'Credit card'
        account_type: 'liability'
      ),
      accountFactory(
        id: 3
        name: 'Opening balances'
        account_type: 'equity'
      ),
      accountFactory(
        id: 4
        name: 'Salary'
        account_type: 'income'
      ),
      accountFactory(
        id: 5
        name: 'Groceries'
        account_type: 'expense'
      )
    ])

    $scope = $rootScope.$new()
    $controller 'EntitiesController', { $scope: $scope }
    controller = $controller 'AccountsController', { $scope: $scope }
    $httpBackend.flush()
  )

  describe '$scope.displayRecords', ->
    it 'is a list of accounts grouped by type', ->
      captions = _.map $scope.displayRecords, (r) -> r.caption()
      expected = ["Asset",
        "Checking",
        "Liability",
        "Credit card",
        "Equity",
        "Opening balances",
        "Income",
        "Salary",
        "Expense",
        "Groceries"
      ]
      expect(captions).toEqual expected

  describe 'new', ->
    it 'sets $scope.formTitle to "New account"', ->
      controller.new()
      expect($scope.formTitle).toEqual "New account"
    it 'sets formAccount to an empty object', ->
      controller.new()
      expect(controller.formAccount).toEqual {}

  describe 'edit', ->
    it 'sets $scope.formTitle to "Edit account"', ->
      controller.edit(2)
      expect($scope.formTitle).toEqual "Edit account"
    it 'sets formAccount to the specified account', ->
      controller.edit(2)
      abbr = _.pick(controller.formAccount, 'name', 'balance')
      expect(abbr).toEqual
        name: 'Credit card'
        balance: 0

  describe 'create', ->
    it 'sends a POST request to the service to create the account', ->
      controller.new()
      controller.formAccount.name = "Rent"
      controller.formAccount.account_type = 'expense'

      $httpBackend.expectPOST('/entities/1/accounts.json', (data) ->
        obj = JSON.parse(data)
        obj.name == 'Rent' && obj.account_type == 'expense'
      ).respond(
        accountFactory(
          id: 6
          name: 'Rent'
          account_type: 'expense'
        )
      )
      controller.create()
      expect($httpBackend.flush).not.toThrow()

    it 'adds the new account to the displayRecords', ->
      controller.new()
      controller.formAccount.name = "Rent"
      controller.formAccount.account_type = 'expense'

      $httpBackend.whenPOST('/entities/1/accounts.json').respond(
        accountFactory(
          id: 6
          name: 'Rent'
          account_type: 'expense'
        )
      )
      controller.create()
      $httpBackend.flush()
      captions = _.map($scope.displayRecords, (r) -> r.caption())
      expect(captions).toEqual [
        'Asset',
        'Checking',
        'Liability',
        'Credit card',
        'Equity',
        'Opening balances',
        'Income',
        'Salary',
        'Expense',
        'Groceries',
        'Rent'
      ]

  describe 'update', ->
    it 'sends a PUT request to the service with the updated data', ->
      $httpBackend.expectPUT('/accounts/2.json', (data) ->
        obj = JSON.parse(data)
        obj.name == 'Mastercard'
      ).respond("")
      controller.edit(2)
      controller.formAccount.name = 'Mastercard'
      controller.update()
      expect($httpBackend.flush).not.toThrow()

    it 'Updates the display record from the updated account', ->
      $httpBackend.whenPUT('/accounts/2.json', (data) ->
        obj = JSON.parse(data)
        obj.name == 'Mastercard'
      ).respond("")
      controller.edit(2)
      controller.formAccount.name = 'Mastercard'
      controller.update()
      $httpBackend.flush()
      account = _.find($scope.accounts, (a) -> a.id == 2)
      expect(account.name).toEqual 'Mastercard'

  describe 'delete', ->
    it 'sends a DELETE request to the service with the account ID', ->
      $httpBackend.expectDELETE('/accounts/2.json').respond("")
      controller.delete(2)
      expect($httpBackend.flush).not.toThrow()

    it 'Removes the display record for the deleted account', ->
      $httpBackend.whenDELETE('/accounts/2.json').respond("")
      controller.delete(2)
      $httpBackend.flush()
      expect(_.map($scope.accounts, (a) -> a.id)).not.toContain(2)
  return
