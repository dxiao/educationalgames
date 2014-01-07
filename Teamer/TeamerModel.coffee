Module = {}
if module? and module.exports?
  module.exports = Module
  _ = require "./Utils.coffee"
else
  window.DebuggerModel = Module
  _ = window.Utils


Module.Problem = class Problem
  constructor: (@name, @description) ->

Module.TestableProblem = class TestableProblem extends Problem
  constructor: (@name, @descrption, @tester) ->

Module.ProblemFamily = class ProblemFamily
  constructor: (@name, @phase, @description, @problems = {}) ->
  addProblems: (problems...) ->
    for problem in problems
      @problems[problem.name] = problem

Module.ProblemSuite = class ProblemSuite
  constructor: (@name, @families = {}) ->
  addFamilies: (families...) ->
    for family in families
      @problems[family.name] = family

Module.Implementation = class Implementation
  constructor: (@user, @problem, @dependencies = []) ->

Module.ProblemRound = class ProblemRound
  constructor: (@problem, @id) ->
    @players = {}
  addPlayer: (player) ->
    unless player.name in @players
      @players[player.name] = player
    else
      throw new Error "Player already added to round!"

Module.Player = class Player
  constructor: (@id, @name) ->
