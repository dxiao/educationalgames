Module = {}
window.DebuggerEngine = Module

_ = window.Utils
Model = window.DebuggerModel

# ---------------- Controllers --------------

Module.ProgramViewer = ($scope) ->
  $scope.program = new Model.ProgramView(20)
    
Module.ProgramControl = ($scope, $server) ->
  $scope.getLines = (linestart) ->
    $server.getProblemLines $scope.debuggerProblem

# ---------------- Services -----------------

Module.Server = class ServerService
  constructor: (@http) ->
  getProblemLines: (problem, line) ->
    @http.get
      url: "/getsource"
      data:
        problem: problem
        line: line

# ---------------- Directives ---------------

Module.DebuggerProblem =
    transduce: true
    link: (scope, element, attributes) ->
      scope.debuggerProblem = attributes["debuggerProblem"]

# ---------------- Angular Module -----------

Module.DebuggerEngine = angular.module('debugger', [])
  .controller("ProgramViewer", Module.ProgramViewer)
  .controller("ProgramControl", ["ServerService", Module.ProgramControl])
  .directive("debuggerProblem", () -> return Module.DebuggerProblem)
  .service("ServerService", ["$http", ServerService])
