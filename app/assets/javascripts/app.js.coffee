#= require angular.min
#= require underscore
#= require app/entities
#= require app/search

app = angular.module 'moneyApp', ['search', 'entities']

app.directive 'confirmationNeeded', ->
  return {
    priority: 1,
    terminal: true,
    link: (scope, element, attr) ->
      msg = attr.confirmationNeeded || "Are you sure you want to proceed with this action?"
      clickAction = attr.ngClick
      element.bind 'click', ->
        scope.$eval clickAction if window.confirm(msg)
  }
