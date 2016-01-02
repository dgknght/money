_.mixin
  ensureDate: (value) ->
    return null if _.isUndefined(value) || _.isNull(value)
    return value if _.isDate(value)
    return _.parseDate(value) if _.isString(value)
    throw "The value \"#{value}\" is not a valid date."
  ensureFunction: (f) ->
    return f if _.isFunction f
    return -> null
  ensureNumber: (value, defaultValue) ->
    return defaultValue if _.isNull(value)
    return value if _.isNumber(value)
    parseFloat(value)
  newString: (character, length) ->
    result = ""
    for n in [0..(length-1)]
      result += character
    result
  parseDate: (value) ->
    match = (/(\d{4})-(\d{2})-(\d{2})/).exec(value)
    return new Date(value) unless match

    year = match[1]
    month = match[2]
    day = match[3]
    new Date(year, month-1, day)
  findById: (list, id) ->
    return _.find(list, (item) -> item.id == id)
  uniqueInt: () ->
    parseInt _.uniqueId()
