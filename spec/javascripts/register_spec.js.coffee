describe 'AccountRegisterController', ->
  beforeEach module('moneyApp')

  $scope = {}
  controller = {}
  $httpBackend = {}

  beforeEach inject( ($controller, $rootScope, _$httpBackend_) ->
    $httpBackend = _$httpBackend_
    $httpBackend
      .whenGET("/accounts/#{CHECKING_ID}/transaction_items.json?per_page=15&page=1")
      .respond (method, url, data, headers, params)->
        match = /^\/accounts\/(\d+)/.exec url
        accountId = match[1]
        items = _.chain(TRANSACTIONS)
          .map( (t) ->
            _.map t.items, (i) ->
              i.description = t.description
              i.transaction_date = t.transaction_date
              i.transaction_id = t.id
              i
          )
          .flatten()
          .filter( (ti) -> ti.account_id == CHECKING_ID)
          .sortBy('transaction_date')
          .reverse()
          .value()
        [200, items]
        
    $httpBackend.whenGET('/assets/transaction-form.html').respond("")

    $scope = $rootScope.$new()
    $scope.accounts = [
      accountFactory
        id: 1
        name: 'Checking'
      ,
      accountFactory
        id: 2
        name: 'Salary'
        account_type: 'income'
    ]
    controller = $controller 'AccountRegisterController', { $scope: $scope }
    return
  )

  describe '$scope.transactionItems', ->
    it 'is empty before the view is displayed', ->
      expect($scope.transactionItems).toEqual []
      return
    it 'contains transaction items for the specified account after the view is displayed', ->
      $scope.activeView = {key: 'account-register', accountId: CHECKING_ID, accountName: 'Checking'}
      $httpBackend.flush()
      actual= _.map($scope.transactionItems, (i) -> [i.transaction_date, i.amount])
      expected = [
        ['2015-01-25',   75]
        ['2015-01-18',   75]
        ['2015-01-15', 1000]
        ['2015-01-11',   75]
        ['2015-01-04',   75]
        ['2015-01-02',  700]
        ['2015-01-01', 1000]
      ]
      expect(actual).toEqual expected

  describe 'new', ->
    it "sets $scope.formTransaction to an object with today's date the first time and two items, one for the current account", ->
      $scope.activeView = {key: 'account-register', accountId: CHECKING_ID, accountName: 'Checking'}
      $httpBackend.flush()
      jasmine.clock().mockDate(new Date(2015, 1, 27))

      controller.new()
      expect($scope.formTransaction.transaction_date).toEqual new Date(2015, 1, 27)
      expect($scope.formTransaction.items[0].account_id).toBe CHECKING_ID
      return

  describe 'edit', ->
    it 'sets formTransaction to the specified item', ->
      $scope.activeView = {key: 'account-register', accountId: CHECKING_ID, accountName: 'Checking'}
      $httpBackend.flush()

      $httpBackend.expectGET(/^\/transactions\/\d+\.json$/).respond( (method, url) ->
        match = /\/transactions\/(\d+)/.exec(url)
        id = parseInt match[1]
        transaction = _.find(TRANSACTIONS, (t) -> t.id == id)
        [200, transaction]
      )

      item = $scope.transactionItems[0]
      controller.edit item
      $httpBackend.flush()

      expect($scope.formTransaction.id).toBe item.transaction_id
      expect($scope.formTransaction.transaction_date).toEqual item.transaction_date
      return
