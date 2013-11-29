Module = {}
module.exports = Module

express = require "express"
http = require "http"
fs = require "fs"
Model = require "./DebuggerModel.coffee"

# ------------- Model ----------------

PROBLEM_TIMEOUT = 2 * 60 * 1000

idCounter = 0
problemNames = ["problem"]

getProgramLinesFromFile = (fileName) ->
  return (new Model.Line(line, i) for line, i in \
    fs.readFileSync(__dirname + "/" + fileName, {encoding: "utf8"}).split("\n"))
  
class ProblemTemplate
  constructor: (@name) ->
    @program = getProgramLinesFromFile(@name + ".js")

class ProblemInstance
  constructor: (@template) ->
    @name = @template.name
    @id = @name + "~" + idCounter
    idCounter++
    @score = 0
    @program = @template.program.slice()

class ProblemsManager
  constructor: (@problemNames) ->
    @templates = {}
    for name in @problemNames
      @templates[name] = new ProblemTemplate name
    @instances = {}

  hasInstance: (id) ->
    if @instances[id]?
      @resetTimer id
      return true
    else
      return false

  newInstance: (name) ->
    instance = new ProblemInstance @templates[name]
    @instances[instance.id] =
      instance: instance
      timeout: setTimeout (() => @removeInstance instance.id), PROBLEM_TIMEOUT
    return instance

  getInstance: (id) ->
    unless @instances[id]?
      return null
    @resetTimer id
    return @instances[id].instance

  removeInstance: (id) ->
    clearTimeout @instances[id].timeout
    delete @instances[id]

  resetTimer: (id) ->
    instance = @instances[id]
    clearTimeout instance.timeout
    instance.timeout = setTimeout (() => @removeInstance id), PROBLEM_TIMEOUT

# ------------- Server ---------------

problemsManager = new ProblemsManager problemNames

Module.useExpressServer = (app) ->
  app.use "/debugger/js", express.static(__dirname + "/js")
  app.use "/debugger/less", express.static(__dirname + "/less")
  app.use "/debugger/images", express.static(__dirname + "/images")
  app.use "/debugger/", express.static(__dirname)

  app.get "/debugger/problem/:problem", (req, res) ->
    problem = req.params.problem
    if problemsManager.hasInstance problem
      return res.sendfile __dirname + "/index.html"
    [name, invalidId] = problem.split "~"
    instance = problemsManager.newInstance name
    unless instance? then return res.send 400, "Problem not found"
    res.redirect "/debugger/problem/" + instance.id

  app.get "/debugger/getinfo", (req, res) ->
    instance = problemsManager.getInstance req.query.problemId
    unless instance? then return res.send 400, "Problem not found"
    res.json 200, {name: instance.template.name}

  app.get "/debugger/getsource", (req, res) ->
    instance = problemsManager.getInstance req.query.problemId
    unless instance? then return res.send 400, "Problem not found"
    line = parseInt req.query.line
    unless line? then return res.send 400, "Line argument not found"
    res.send 200, (line.toJson() for line in instance.program.slice(line, line+7))
