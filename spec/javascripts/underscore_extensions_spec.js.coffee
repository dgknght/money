describe 'Underscore extensions', ->
  describe 'ensureDate', ->
    it 'returns null if given a null value', ->
      result = _.ensureDate(null)
      expect(result).toBeNull()
    it 'returns null if given an undefined value', ->
      obj = {}
      result = _.ensureDate(obj.notADefinedValue)
      expect(result).toBeNull()
    it 'returns the value if give a date value', ->
      val =  new Date(2015, 2, 2)
      result = _.ensureDate val
      expect(result).toBe val
    it 'returns the parsed date if given a serialized date', ->
      result = _.ensureDate('2015-02-27')
      expect(result).toEqual new Date(2015, 1, 27)
    it 'throws an exception if given a value that is not a string or a date', ->
      expect(-> _.ensureDate({})).toThrow()
    return
  describe 'ensureFunction', ->
    it 'returns the val if given a function', ->
      f = -> 1 + 1
      result = _.ensureFunction f
      expect(result).toBe f
    it 'returns a no-op function if given something that is not a function', ->
      result = _.ensureFunction ""
      expect(_.isFunction(result)).toBe true
    return
  describe 'newString', ->
    it 'returns a string of the specified length containing repititions of the specified character', ->
      result = _.newString('a', 10)
      expect(_.isString(result)).toBe true
      expect(result.length).toBe 10
      _.each(result, (c) -> expect(c).toEqual 'a')
  describe 'findById', ->
    it 'returns the value having a property "id" with the specified value', ->
      list = [
        id: 1
        name: "John Doe"
      ,
        id: 2
        name: "Jane Doe"
      ]
      result = _.findById(list, 2)
      expect(result).not.toBeNull()
      expect(result.name).toEqual "Jane Doe"
    return
  describe 'uniqueInt', ->
    it 'returns a number', ->
      result = _.uniqueInt()
      expect(_.isNumber result).toBe true
