Module = {}
module.exports = Module

express = require "express"
http = require "http"
fs = require "fs"
Model = require "./TeamerModel.coffee"

# URL model:
# /teamer/login
# /teamer/admin
# /teamer/lobby
# /teamer/problem/sql/start
# /teamer/problem/sql/phase1
# /teamer/problem/sql/phase2
# /teamer/problem/sql/phase3
# /teamer/problem/sql/results
#
# API model:
# login(user):token  -- (split into password system later)
#   All Stages
# getProblems():string[]
# getProblemInfo(problem):problemInfo
# //get the state of the implementation
# getProblemStatus(problem):problemStatus
# //Stage 1:
# submitFunction(token, function, impl)
# //Stage 2:
# getImplementations(token, problem)
# 

# ------------- Model ----------------

problems = {}
problems.sql = require "./problems/sql.coffee"

class PlayerRegistry
  constructor: () ->
    @players = {}
  getNextUnusedId: () ->
    loop
      newId = Math.floor Math.random()*1000000
      unless newId in @players
        return newId
  createNewPlayer: (name) ->
    for id, player of @players
      if player.name == name
        return false
    newId = @getNextUnusedId()
    newPlayer = new Model.Player newId, name
    @players[newId] = newPlayer
    return newId

playerRegistry = new PlayerRegistry()

# ------------- Server ---------------

Module.useExpressServer = (app) ->
  app.use "/teamer/js", express.static(__dirname + "/js")
  app.use "/teamer/less", express.static(__dirname + "/less")
  app.use "/teamer/images", express.static(__dirname + "/images")

  app.get "/teamer", (req, res) ->
    res.sendfile __dirname + "/index.html"

  app.get "/teamerapi/getProblems", (req, res) ->
    res.json Object.keys problems
  app.get "/teamerapi/problem/:problem/start", (req, res) ->
    
  app.get "/teamerapi/problem/:problem/getFunctions", (req, res) ->
  app.get "/teamerapi/login", (req, res) ->
    name = req.query.name
    id = playerRegistry.createNewPlayer name
    if id
      console.log id + "!!!!!!!!!!"
      res.send 200, id + ""
    else
      console.log id + "??????????"
      res.send 409, "User name " + name + " already taken, please try another."

console.log Object.keys(problems)
