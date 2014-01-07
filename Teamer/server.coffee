Module = {}
module.exports = Module

express = require "express"
http = require "http"
fs = require "fs"
Model = require "./TeamerModel.coffee"

# URL model:
# /teamer/problem/sql/lobby
# /teamer/problem/sql/start
# /teamer/problem/sql/phase1
# /teamer/problem/sql/phase1review
# /teamer/problem/sql/phase2
# /teamer/problem/sql/phase2review
# /teamer/problem/sql/results

# ------------- Model ----------------

problems = {}
problems.suite = require "./problems/sql.coffee"

# ------------- Server ---------------

Module.useExpressServer = (app) ->
  app.use "/teamer/js", express.static(__dirname + "/js")
  app.use "/teamer/less", express.static(__dirname + "/less")
  app.use "/teamer/images", express.static(__dirname + "/images")

