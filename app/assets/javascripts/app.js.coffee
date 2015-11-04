#= require angular.min
#= require app/entities

app = angular.module 'moneyApp', ['entities']
app.controller 'SearchController',
  ->
    _self = this
    @input = ""
    @matches = []
    @handlers = [
      new ManageEntitiesHandler(),
      new AddAccountHandler()
    ]
    @execute = ->
      if @input && @input.length > 2
        matches = for handler in @handlers
          handler.handle(@input)
        _self.matches = matches.filter (m) -> !!m
      else
        _self.matches = []
    @select = (index) ->
      _self.matches[index].handler.render()
      _self.matches = []
      _self.input = ""
    @selectFirst = (e) ->
      return unless e.keyCode == 13
      _self.select(0)
    return

ManageEntitiesHandler = ->
  _self = this
  @handle = (input) ->
    re = RegExp(input, "i")
    isMatch = ["entity", "entities"].reduce (result, term) ->
      result || re.test(term)
    , false
    if isMatch
      return {description: "Manage entities", handler: _self}
    else
      return null
  @render = ->
    console.log "Manage entities"
  return

AddAccountHandler = ->
  _self = this
  @handle = (input) ->
    re = RegExp(input, "i")
    if re.test("add")
      return {description: "Add account", handler: _self}
    else
      return null
  @render = ->
    console.log "add an account"
  return
