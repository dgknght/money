#= require angular.min
#= require app/entities

app = angular.module 'moneyApp', ['entities']
app.controller 'SearchController',
  class SearchController
    input: ""
    matches: []
