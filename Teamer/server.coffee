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
# getProblemStatus(problem):problemStatus
#   Stage 1:
# submitFunction(token, function, impl)
#   Stage 2:
# getImplementations(token, problem)
# 

# ------------- Model ----------------

problems = {}
problems.suite = require "./problems/sql.coffee"

# ------------- Server ---------------

Module.useExpressServer = (app) ->
  app.use "/teamer/js", express.static(__dirname + "/js")
  app.use "/teamer/less", express.static(__dirname + "/less")
  app.use "/teamer/images", express.static(__dirname + "/images")

  app.get "/teamer", (req, res) ->
    res.render 'index.html', (err, html) ->
      console.log err


