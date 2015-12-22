#= require jquery-2.0.3.min
#= require bootstrap.min
#= require angular.min
#= require ui-bootstrap-tpls-0.14.3.min
#= require underscore
#= require app/view
#= require app/entities
#= require app/accounts
#= require app/register
#= require app/transactions

app = angular.module 'moneyApp', ['view', 'entities', 'accounts', 'register', 'transactions']

app.directive 'confirmationNeeded', ->
  {
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

app.directive 'convertToNumber', ->
  {
    require: 'ngModel',
    link: (scope, element, attrs, ngModel) ->
      ngModel.$parsers.push (val) ->
        parseInt val, 10
      ngModel.$formatters.push (val) ->
        '' + val
  }

app.directive 'convertToDate', ($filter) ->
  {
    require: 'ngModel',
    link: (scope, element, attrs, ngModel) ->
      ngModel.$parsers.push (val) ->
        new Date(val)
      ngModel.$formatters.push (val) ->
        $filter('date') val, 'M/d/yyyy'
  }

app.directive 'infiniteScroll', ->
  {
    restrict: 'A',
    link: (scope, element, attrs) ->
      elem = element[0]
      element.on 'scroll', _.throttle ->
        availableHeight = elem.scrollHeight - (elem.scrollTop + elem.offsetHeight)
        scope.$apply(attrs.infiniteScroll) if availableHeight < elem.offsetHeight
        return
      , 200
  }
