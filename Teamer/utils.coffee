Module = {}
if module? and module.exports?
  module.exports = Module
else
  window.Utils = Module

# -------------- Utilities Module ---------------

Module.extend = (obj, mixin) ->
  (obj[name] = method for name, method of mixin)
  obj

Module.copy = (obj) ->
  extend {}, obj

Module.newElement = (tag) ->
  $ document.createElement tag

Module.assert = (condition, message) ->
  unless condition
    throw new Error "ASSERT: " + message

Module.pad = (str, num, char) ->
  char = " " unless char?
  len = (str + "").length
  str + (if num > len then Module.repeatStr(char, num - len) else "")

Module.repeatStr = (str, count) ->
  (str for i in [0...count]).join("")

Module.randInt = (min, max) ->
  Math.floor Math.random()*(max-min) - min

Module.mapToList = (map, additionalDepth) ->
  result = []
  if additionalDepth > 0
    for key, val of map
      result = result.concat Module.mapToList val, additionalDepth-1
  else
    for key, val of map
      result.push val
  result
