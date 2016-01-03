describe 'EntitiesController', ->
  beforeEach module('moneyApp')

  controller = {}
  $scope = {}
  $httpBackend = {}

  beforeEach inject( ($controller, $rootScope, _$httpBackend_) ->
    $httpBackend = _$httpBackend_
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

  describe 'add', ->
    it 'sends a POST message to the service to add the new entity', ->
      $httpBackend.expectPOST('/entities.json', (data) ->
        obj = JSON.parse(data)
        obj.entity.name == 'Test'
      ).respond(
        id: 3
        name: 'Test'
      )

      controller.newEntityName = 'Test'
      controller.add()
      expect($httpBackend.flush).not.toThrow()

    it 'adds the new entity to the entities collection', ->
      $httpBackend.whenPOST('/entities.json')
        .respond(
          id: 3
          name: 'Test'
        )

      controller.newEntityName = 'Test'
      controller.add()
      $httpBackend.flush()
      expect(controller.entities).toContain { id: 3, name: 'Test' }

  describe 'save', ->
    it 'sends a PUT message to the service to update the selected entity', ->
      $httpBackend.expectPUT('/entities/2.json', (data) ->
        obj = JSON.parse(data)
        obj.entity.name == 'Bidness'
      ).respond("")

      controller.entities[1].name = 'Bidness'
      controller.save(controller.entities[1])
      expect($httpBackend.flush).not.toThrow()

  describe 'delete', ->
    it 'sends a DELETE Message to the service to remove the entity', ->
      $httpBackend.expectDELETE('/entities/2.json').respond("")
      controller.delete(controller.entities[1].id)
      expect($httpBackend.flush).not.toThrow()

    it 'removes the entity from the entities collection', ->
      $httpBackend.whenDELETE('/entities/2.json').respond("")
      controller.delete(controller.entities[1].id)
      $httpBackend.flush()
      expect(controller.entities).not.toContain { id: 2, name: 'Business'}
