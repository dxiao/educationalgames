Module = {}
window.ClassModel = Module

# --------------Utility Code----------------

extend = (obj, mixin) ->
  (obj[name] = method for name, method of mixin)
  obj

copy = (obj) ->
  extend {}, obj

# --------------Class Model-----------------

Module.Model = class Model
  constructor: (@types) ->

class ModelObject
  constructor: (@name, @modifiers = []) ->
  toString: ->
    return @name + @modifiers.join()

class Type extends ModelObject
  constructor: (name, modifiers, @parents = [], @fields = {}, @methods = {}) ->
    super name, modifiers

class Method extends ModelObject
  constructor: (name, modifiers, @parameters = {}, @return) ->
    super name, modifiers

class Field extends ModelObject
  constructor: (name, modifiers, @type) ->
    super name, modifiers

# Type with no methods
class Struct extends Type
  constructor: (name, modifiers, @parents, @fields) ->
    super name, modifiers, parents, fields

# Type with methods or fields
class Class extends Type
  constructor: (name, modifiers, @parents, @fields, @methods) ->
    super name, modifiers, parents, fields, methods

# Type with no fields
class Interface extends Type
  constructor: (name, modifiers, @parents, @methods) ->
    super name, modifiers, parents, null, methods

