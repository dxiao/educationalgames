Module = {}
if module? and module.exports?
  module.exports = Module
  _ = require "./utils.coffee"
else
  window.TeamerModel = Module
  _ = window.Utils

# Problem Description

Module.Function = class Function
  constructor: (@name, family, @description) ->
    @family = family.name
    @phase = family.phase

Module.FunctionFamily = class FunctionFamily
  constructor: (@name, @phase, @description) ->

Module.ProblemSuite = class ProblemSuite
  constructor: (@name, @functions = {}) ->
    @functions = {}
    @families = {}
  addFunctions: (functions...) ->
    for func in functions
      @functions[func.name] = func
  addFamilies: (families...) ->
    for fam in families
      @families[fam.name] = fam

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

Module.GameInfo = class GameInfo
  constructor: (@gameName, @gameStatus, @families) ->
  @fromJson: (json) ->
    return new GameInfo json.gameName, GameStatus.fromJson(json.gameStage),
      json.families

Module.GameStatus = class GameStatus
  constructor: (@gameStage, @stageEnd) ->
  @fromJson: (json) ->
    return new GameStatus json.gameStage, json.stageEnd
    
# User Information

Module.Player = class Player
  constructor: (@id, @name) ->

Module.PlayerView = class PlayerView
  constructor: (@player, @functions) ->
    @impl = {}
  addImplementation: (impl) ->
  toJson: () ->
  @fromJson: (json) ->

