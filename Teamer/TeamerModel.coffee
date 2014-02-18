Module = {}
if module? and module.exports?
  module.exports = Module
  _ = require "./utils.coffee"
else
  window.TeamerModel = Module
  _ = window.Utils

# Problem Description

Module.Function = class Function
  constructor: (@name, @family, @description) ->
    @phase = @family.phase
  toJson: () -> {
    name: @name
    family: @family.name
    description: @description
  }
  @fromJson: (json, families) ->
    console.log families
    new Function json.name, families[json.family], json.description
    

Module.FunctionFamily = class FunctionFamily
  constructor: (@name, @phase, @description) ->
  toJson: () -> @
  @fromJson: (json) ->
    new FunctionFamily json.name, json.phase, json.description

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
  constructor: (@function, @player, @code) ->
    @_dirty = false
  toJson: () -> {
      function: @function.name
      player: @player.id
      code: code
    }
  @fromJson: (json, functions, players) ->
    new Implementation functions[json.function], players[json.player], code

# Problem State

Module.GameInfo = class GameInfo
  constructor: (@name, @status, @families, @players) ->
  toJson: () -> @
  @fromJson: (json) ->
    players = {}
    for id, player of json.players
      players[id] = Player.fromJson player
    families = {}
    for id, family of json.families
      families[id] = Player.fromJson family
    new GameInfo json.name, GameStatus.fromJson(json.status), families, players

Module.GameStatus = class GameStatus
  constructor: (@stage, @endTime) ->
  toJson: () -> @
  @fromJson: (json) ->
    return new GameStatus json.stage, json.endTime
    
# User Information

Module.Player = class Player
  constructor: (@id, @name) ->
  toJson: () -> @
  @fromJson: (json) ->
    new Player json.id, json.name

Module.PlayerView = class PlayerView
  constructor: (@player, @game) ->
    @functions = []
    @impls = []
  toJson: () -> {
    player: @player.id,
    game: @game.name,
    functions: (func.toJson() for func in @functions)
    impls: (impl.toJson() for impl in  @impls)
  }
  @fromJson: (json, game) ->
    gamePlayer = new PlayerView game.players[json.player], game
    gamePlayer.functions = (Function.fromJson(func, game.families) for func in json.functions)
    gamePlayer.impls = (Implementation.fromJson(impl, gamePlayer.functions, game.players) for impl in json.impls)
    gamePlayer

