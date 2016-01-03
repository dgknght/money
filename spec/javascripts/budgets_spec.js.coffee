describe 'BudgetsController', ->
  controller = {}
  $httpBackend = {}
  $scope = {}

  beforeEach ->
    module 'moneyApp'
    inject ($controller, $rootScope, _$httpBackend_) ->
      $scope = $rootScope.$new()
      $httpBackend = _$httpBackend_
      BUDGET_ID = _.uniqueInt()
      $httpBackend.whenGET('/entities/1/budgets.json').respond [
        id: BUDGET_ID
        name: '2016'
        start_date: '2016-01-01'
      ,
        id: _.uniqueInt()
        name: '2015'
        start_date: '2015-01-01'
      ]
      $httpBackend.whenGET("/budgets/#{BUDGET_ID}/items.json").respond [
      ]
      $httpBackend.whenGET('budget-form.html').respond ''
      controller = $controller 'BudgetsController', { $scope: $scope }
      $scope.currentEntityId = 1
      $httpBackend.flush()
      return
    return

  describe 'budgets', ->
    it 'contains a list of existing budgets', ->
      names = _.map(controller.budgets, (b) -> b.name)
      expect(names).toEqual ["2016", "2015"]
    return
  describe 'new', ->
    it 'sets up the formBudget property', ->
      controller.new()
      expect(controller.formBudget).toEqual
        period: 'month'
        period_count: 12
    it 'sets $scope.budgetFormTitle', ->
      controller.new()
      expect($scope.budgetFormTitle).toBe "New budget"
    return
  describe 'createBudget', ->
    beforeEach ->
      NEW_BUDGET_ID = _.uniqueInt()
      $httpBackend.expectPOST('/entities/1/budgets.json', (data) ->
        obj = JSON.parse(data)
        budget = obj.budget
        budget.name == '2017' && budget.start_date = '1/1/2017'
      ).respond
        id: NEW_BUDGET_ID
        name: '2017'
        start_date: '2017-01-01'
      $httpBackend.expectGET("/budgets/#{NEW_BUDGET_ID}/items.json").respond []
      controller.new()
      controller.formBudget.name = '2017'
      controller.formBudget.start_date = '1/1/2017'
    it 'sets a POST message to the service to create the budget', ->
      controller.createBudget()
      expect($httpBackend.flush).not.toThrow()
    it 'selects the new budget', ->
      controller.createBudget()
      $httpBackend.flush()
      expect(controller.selectedBudget.name).toBe '2017'
    it 'sets formBudget to null', ->
      controller.createBudget()
      $httpBackend.flush()
      expect(controller.formBudget).toBeNull()
    it 'adds the new budgets to the budgets list', ->
      controller.createBudget()
      $httpBackend.flush()
      names = _.map(controller.budgets, (b) -> b.name)
      expect(names).toEqual ['2017', '2016', '2015']
    return
  describe 'edit', ->
    it 'sets the formBudget property to the selected budget', ->
      controller.edit()
      expect(controller.formBudget.name).toBe '2016'
    it 'sets the $scope.budgetFormTitle', ->
      controller.edit()
      expect($scope.budgetFormTitle).toBe 'Edit budget'
    return
  describe 'updateSelectedBudget', ->
    beforeEach ->
      $httpBackend.expectPUT("/budgets/#{controller.budgets[0].id}.json", (data) ->
        obj = JSON.parse(data)
        budget = obj.budget
        budget.name == 'Twenty Fifteen'
      ).respond("")
      controller.edit()
      controller.formBudget.name = 'Twenty Fifteen'
    it 'sends a PUT message to the service to update the budget', ->
      controller.updateSelectedBudget()
      expect($httpBackend.flush).not.toThrow()
    it 'updates the budget in the budgets collection', ->
      controller.updateSelectedBudget()
      $httpBackend.flush()
      names = _.map(controller.budgets, (b) -> b.name)
      expect(names).toContain 'Twenty Fifteen'
    it 'sets formBudget to null', ->
      controller.updateSelectedBudget()
      $httpBackend.flush()
      expect(controller.formBudget).toBeNull()
    return
  describe 'items', ->
    it 'contains an entry for every account in the entity'
    it 'contains header items for each account type' #TODO Eventually change this to tags for Mandatory, Discretionary, etc.
    it 'contains zero values for accounts without budget items'
    it 'contains the budgeted amounts for accounts with items'
  describe 'createBudgetItem', ->
    #beforeEach ->
    #  $httpBackend.expectPOST("/budgets/#{BUDGET_ID}/items.json", (data) ->
    #    obj = JSON.parse(data)
    #    item = obj.budget_item
    #    budget_item.account_id == RENT_ID
    #  ).respond
    #    id: _.uniqueInt()
    #    account_id: RENT_ID
    #    periods: _.map [0..12], (month) ->
    #      id: _.uniqueInt()
    #      amount: 800
    #      start_date: $filter('date')(new Date(2016, month 1), 'yyyy-MM-dd')
    #  controller.editItem() # How to get the item?
    it 'sends a POST request to the service to create the item'
    it 'adds the budget item to the list of budget items'
    return
  describe 'updateSelectedBudgetItem', ->
    it 'sends a PUT request to the service to update the item'
    it 'updates the item in the list of budget items'
  describe 'openCalendar', ->
    it 'sets calendarIsOpen to true', ->
      controller.openCalendar()
      expect(controller.calendarIsOpen).toBe true
