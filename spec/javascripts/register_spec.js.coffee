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
              i
          )
          .flatten()
          .filter( (ti) -> ti.account_id == CHECKING_ID)
          .sortBy('transaction_date')
          .reverse()
          .value()
        [200, items]
        
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
      $scope.activeView = {key: 'account-register', accountId: 1, accountName: 'Checking'}
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

