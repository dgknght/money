#= require angular.min
#= require ui-bootstrap-tpls-0.14.3.min
#= require underscore
#= require app/search
#= require app/entities
#= require app/accounts

app = angular.module 'moneyApp', ['search', 'entities', 'accounts']

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

app.directive 'focusOn', ($timeout) ->
  {
    restrict: 'A',
    link: ($scope, $element, $attr) ->
      $scope.$watch $attr.focusOn, (_focusVal) ->
        $timeout ->
          if _focusVal
            $element.focus()
          else
            $element.blur()
        , 500
  }
