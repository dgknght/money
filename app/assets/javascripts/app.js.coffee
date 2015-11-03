#= require angular.min
app = angular.module 'moneyApp', []
app.controller 'SearchController',
  class SearchController
    searchText: ""
    matches: []
