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
      .respond([])
    $scope = $rootScope.$new()
    controller = $controller 'EntitiesController', { $scope: $scope }
    $httpBackend.flush()
  )

  describe 'entities', ->
    it 'contains the entities available to the user', ->
      expect(controller.entities).toEqual [
        id: 1
        name: 'Personal'
      ,
        id: 2
        name: 'Business'
      ]
