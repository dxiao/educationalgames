Module = {}
window.ClassView = Module

ClassModel = window.ClassModel

# --------------Utility Code----------------

extend = (obj, mixin) ->
  (obj[name] = method for name, method of mixin)
  obj

copy = (obj) ->
  extend {}, obj

newElement = (tag) ->
  $ document.createElement tag

# --------------Class View------------------


