describe 'ViewController', ->
  beforeEach module('moneyApp')

  controller = {}
  $scope = {}

  beforeEach inject( ($controller, $rootScope) ->
    $scope = $rootScope.$new()
    controller = $controller 'ViewController', { $scope: $scope }
  )

  describe 'search', ->
    it 'populates the matches collection', ->
      controller.searchInput = 'Account'
      controller.search()
      expect(controller.matches.length).not.toBe 0
    it 'finds the entity manager with the input "ent"', ->
      controller.searchInput = 'ent'
      controller.search()
      matches = _.map controller.matches, (m) -> m.description
      expect(matches).toContain "Manage entities"
    it 'finds the account manager with the input "acc"', ->
      controller.searchInput = 'acc'
      controller.search()
      matches = _.map controller.matches, (m) -> m.description
      expect(matches).toContain "Manage accounts"
    it 'finds the budget manager with the input "bud"', ->
      controller.searchInput = 'bud'
      controller.search()
      matches = _.map controller.matches, (m) -> m.description
      expect(matches).toContain "Manage budgets"
    it 'finds the purchase entry form with the input "pur"', ->
      controller.searchInput = 'pur'
      controller.search()
      matches = _.map controller.matches, (m) -> m.description
      expect(matches).toContain "Enter purchases"
    it 'finds the an account register with the name of an account'#, ->
      #controller.searchInput = 'Check'
      #controller.search()
      #matches = _.map controller.matches, (m) -> m.description
      #expect(matches).toContain "Register: Checking"

  return
