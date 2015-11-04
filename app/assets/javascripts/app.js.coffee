#= require angular.min
#= require app/entities

app = angular.module 'moneyApp', ['entities']
app.controller 'SearchController',
  ->
    _self = this
    @input = ""
    @matches = []
    @handlers = [
      new AddEntityHandler(),
      new AddAccountHandler()
    ]
    @execute = ->
      if !@input
        _self.matches = []
      else
        matches = for handler in @handlers
          handler.handle(@input)
        _self.matches = matches.filter (m) -> !!m
    @select = (index) ->
      _self.matches[index].handler.render()
      _self.matches = []
      _self.input = ""
    return

AddEntityHandler = ->
  _self = this
  @handle = (input) ->
    re = RegExp(input, "i")
    if re.test("add")
      return {description: "Add entity", handler: _self}
    else
      return null
  @render = ->
    console.log "add an entity"
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
