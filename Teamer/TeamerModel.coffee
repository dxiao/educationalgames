Module = {}
if module? and module.exports?
  module.exports = Module
  _ = require "./utils.coffee"
else
  window.DebuggerModel = Module
  _ = window.Utils

# Problem Description

Module.Function = class Function
  constructor: (@name, @family, @description) ->
    @phase = family.phase

Module.FunctionFamily = class FunctionFamily
  constructor: (@name, @phase, @description) ->

Module.ProblemSuite = class ProblemSuite
  constructor: (@name, @functions = {}) ->
    @functions = {}
  addFunctions: (functions...) ->
    for func in functions
      @functions[func.name] = func

# Problem Submissions

Module.Implementation = class Implementation
  constructor: (@function, @user, @code) ->

Module.ProblemRound = class ProblemRound
  constructor: (@problem, @id) ->
    @players = {}
  addPlayer: (player) ->
    unless player.name in @players
      @players[player.name] = player
    else
      throw new Error "Player already added to round!"

# Problem State

Module.ProblemState = class ProblemState
  constructor: (@problem, @starttime) ->
    @implementations = {} # problem -> implementation
    @feedback = {} # implementation -> feedback
  addImplementation: (implementation) ->
    
# User Information

Module.Player = class Player
  constructor: (@id, @name) ->
