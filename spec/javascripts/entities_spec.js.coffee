describe 'EntitiesController', ->
  beforeEach module('moneyApp')

  controller = {}
  $scope = {}

  beforeEach inject( ($controller, $rootScope, $httpBackend) ->
    $httpBackend
      .when('GET', '/entities.json')
      .respond([
        id: 1
        name: 'Personal'
      ,
        id: 2
        name: 'Business'
      ])
    $httpBackend
      .when('GET', '/entities/1/accounts.json')
      .respond([
        accountFactory(
          id: 1
          entity_id: 1
          name: 'Checking'
        )
        ,
        accountFactory(
          id: 2
          entity_id: 1
          name: 'Salary'
          account_type: 'income'
        )
      ])

    $scope = $rootScope.$new()
    controller = $controller 'EntitiesController', { $scope: $scope }
    $httpBackend.flush()
  )

  describe 'entities', ->
    it 'contains the entities available to the user', ->
      entityNames = _.map(controller.entities, (e) -> e.name)
      expect(entityNames).toEqual ['Personal', 'Business']

  describe '$scope.accounts', ->
    it 'contains the accounts for the entity', ->
      $scope.currentEntityId = 1
      accountNames = _.map($scope.accounts, (a) -> a.name)
      expect(accountNames).toEqual ['Checking', 'Salary']
