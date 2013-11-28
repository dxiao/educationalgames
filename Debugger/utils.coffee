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
  return str + (if num > len then Module.repeatStr(char, num - len) else "")

Module.repeatStr = (str, count) ->
  return (str for i in [0...count]).join("")
