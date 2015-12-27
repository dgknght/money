#= require jquery-2.0.3.min
#= require bootstrap.min
#= require angular.min
#= require ui-bootstrap-tpls-0.14.3.min
#= require underscore
#= require underscore_extensions
#= require app/view
#= require app/entities
#= require app/accounts
#= require app/register
#= require app/transactions
#= require app/budgets


window.today = ->
  d = new Date()
  new Date(d.getFullYear(), d.getMonth(), d.getDate())
window.parseDate = (dateString) ->
  parsed = /^(\d{4})-(\d{2})-(\d{2})$/.exec(dateString)
  year  = parseInt(parsed[1])
  month = parseInt(parsed[2])
  date  = parseInt(parsed[3])
  new Date(year, month - 1, date)
window.addMonths = (date, monthCount) ->
  new Date(date.getFullYear(), date.getMonth() + monthCount, date.getDate())
window.consecutiveMonths = (date, count) ->
  _.map([0..(count-1)], (index) -> addMonths(date, index))

app = angular.module 'moneyApp', ['view', 'entities', 'accounts', 'register', 'transactions', 'budgets']

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

app.directive 'uniqueValue', ->
  {
    restrict: 'A',
    require: 'ngModel',
    link: (scope, elem, attrs, ctrl) ->
      opts = scope.$eval attrs.uniqueValue
      existing = opts.collection
      existing = _.reject(existing, (obj) -> obj.id == opts.except) if opts.except
      existing = _.map(existing, (obj) -> obj['name'])
      ctrl.$validators.uniqueValue = (modelValue, viewValue) ->
        !_.find(existing, (v) -> v == viewValue)
  }
