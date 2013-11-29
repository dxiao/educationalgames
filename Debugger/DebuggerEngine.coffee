Module = {}
window.DebuggerEngine = Module

_ = window.Utils
Model = window.DebuggerModel

# ---------------- Controllers --------------

Module.ProgramViewer = ($scope) ->
    
Module.ProgramControl = ($scope, server) ->
  $scope.getLines = (lineStart) ->
    server.getProblemLines $scope.problemId, lineStart, $scope.program

# ---------------- Services -----------------

Module.Server = class ServerService
  constructor: (@http, @location) ->

  getProblemId: () ->
    @location.absUrl().split("/").slice(-1)[0]

  getProblemLines: (problem, line, view) ->
    query = @http.get "/debugger/getsource",
      params:
        problemId: problem
        line: line
    query.success (data) ->
      view.setLines (Model.Line.fromJson line for line in data)

# ---------------- Directives ---------------

Module.DebuggerProblem =
    transduce: true
    link: (scope, element, attributes) ->
      scope.debuggerProblem = attributes["debuggerProblem"]

# ---------------- Angular Module -----------

Module.DebuggerEngine = angular.module('debugger', [])
  .controller("ProgramViewer", Module.ProgramViewer)
  .controller("ProgramControl", ["$scope", "ServerService", Module.ProgramControl])
  .directive("debuggerProblem", () -> return Module.DebuggerProblem)
  .service("ServerService", ["$http", "$location", ServerService])
  .run(["$rootScope", "ServerService", (scope, server) ->
    scope.problemId = server.getProblemId()
    scope.program = new Model.ProgramView(20)])
