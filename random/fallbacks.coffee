# This file contains various built-in type methods. Usually almost all of them
# are implemented natively by ES5 browsers
String::trim ?= -> @replace /^\s+|\s+$/g, ''

Array::indexOf ?= (searchElem) ->
  if @ is undefined or @ is null
    throw new TypeError()
  len = @length >>> 0
  return -1 if len is 0
  for item, i in @
    return i if item is searchElem
  return -1

Array::map ?= (callback) -> (callback(i) for i in @)
Array::filter ?= (predicate) -> (i for i in @ when predicate(i))
Array::reduce ?= (callback, initialValue) ->
  if typeof callback isnt 'function'
    throw new TypeError('First argument is not callable')
  len = @length
  if len is 0 and initialValue is undefined
    throw new TypeError('Empty array and no second argument')
  if initialValue isnt undefined
    accumulator = initialValue
    from = 0
  else
    accumulator = @[0]
    from = 1
  for i in [from...len]
    accumulator = callback.call(undefined, accumulator, @[i], i, @)
  return curr

Array::some ?= (predicate = (item) -> item) ->
  for i in @
    return true if predicate(i)
  return false

Array::every ?= (predicate = (item) -> item) ->
  for i in @
    return false if not predicate(i)
  return true

Array.isArray ?= (arg) ->
  return false if arg is null or arg is undefined or not arg.constructor
  arg.constructor.toString().indexOf('Array') isnt -1
