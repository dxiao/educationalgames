Model = window.TeamerModel

class PlayerAuth
  @$inject = ['$http', '$location']

  constructor: ($http, $location) ->
    @http = $http
    @location = $location

  submitLogin: (name, callback) ->
    @http {
      method: 'GET',
      url: '/teamerapi/login'
      params: {name: name}
    }
    .success (data, status) =>
      @player = new Model.Player data, name
      callback @player, null
    .error (data, status) ->
      callback null, data

  assertLoggedIn: () ->
    unless @player?
      console.log "AUTH: no player found, redirecting to login"
      @location.path "/login"
      return false
    else
      return @player

class ProblemServer
  @$inject = ['$http', '$location', 'playerAuth']

  constructor: ($http, $location, @playerAuth) ->
    @http = $http
    @location = $location

  updateConfig: () ->
    @problem = @location.path().split("/")[2]
    @id = @playerAuth.player?.id

  getFunctions: () ->
    @updateConfig()
    @http {
      method: 'GET'
      url: '/teamerapi/game/' + @problem + '/getFunctions'
      params: {id: @id}
    }

  getView: () ->
    @http {
      method: 'GET'
      url: '/teamerapi/game/' + @problem + '/getView'
      params: {id: @id}
    }

  joinGame: () ->
    @updateConfig()
    @http {
      method: 'GET'
      url: '/teamerapi/game/' + @problem + '/joinGame'
      params: {id: @id}
    }

  submitImpl: (impl) ->
    @http {
      method: 'POST'
      url: '/teamerapi/game/' + @problem + '/submitImpl'
      params: {id: @id}
      data: impl.toJson()
    }

angular.module 'teamer', ['ngRoute']
  .config ($routeProvider, $locationProvider) ->
    $routeProvider
      .when '/login', {
        templateUrl: 'teamer/views/login.html'
        controller: 'LoginController'
      }
      .when '/problem/:problem', {
        templateUrl: 'teamer/views/problem.html'
        controller: 'ProblemController'
      }
      .otherwise {
        templateUrl: 'teamer/views/null.html'
        controller: 'InitController'
      }

  .controller 'LoginController', ['$scope', '$location', 'playerAuth',
  ($scope, $location, playerAuth) ->
    $scope.submitName = () ->
      $scope.loginError = false
      $scope.id = playerAuth.submitLogin $scope.loginname, (player, error) ->
        if player
          $location.path ""
        else
          $scope.loginError = error
  ]

  .controller 'InitController', ['$location', 'playerAuth',
  ($location, playerAuth) ->
    if playerAuth.assertLoggedIn()
      console.log "INIT: player detected, redirecting to problem"
      $location.path "/problem/sql/"
  ]

  .controller 'ProblemController', ['$scope', 'playerAuth', 'problemServer',
  ($scope, playerAuth, server) ->
    unless playerAuth.assertLoggedIn()
      return

    server.joinGame()
    .then (data) ->
      $scope.game = Model.GameInfo.fromJson data.data
      server.getView()
    .then (data) ->
      $scope.view = Model.PlayerView.fromJson data.data, $scope.game
      $scope.view.createImplsForStage 1
    .catch (error) ->
      $scope.error = error

    $scope.openImpl = (impl) ->
      console.log "PROBCTL: changing function to " + impl.function.name
      $scope.activeImpl = impl

    $scope.codeEditor = {}

    $scope.submitImpl = () ->
      $scope.activeImpl.code = $scope.codeEditor.editor.getValue()
      console.log "PROBCTL: submitting implementation for " + $scope.activeImpl.function.name
      server.submitImpl $scope.activeImpl
      .then (data) ->
        $scope.info = data.data
        $scope.activeImpl._dirty = false
      .catch (error) ->
        $scope.error = error
  ]

  .directive 'countdownTimer', ['dateFilter', '$interval'
  (dateFilter, $interval) ->
    format = "m:ss 'Remaining'"
    (scope, element, attrs) ->
      stageEndTime = 0
      updateTime = () ->
        element.text dateFilter stageEndTime - Date.now(), format

      scope.$watch attrs.countdownTimer, (value) ->
        stageEndTime = value
        updateTime()

      timer = $interval updateTime, 1000

      element.bind '$destroy', () ->
        $interval.cancel timer
  ]

  .directive 'functionEditor', () ->
    (scope, element, attrs) ->
      editor = CodeMirror element[0], {
        value: "use strict;"
        mode: "javascript"
        lineNumbers: true
      }
      scope.codeEditor.editor = editor
      scope.$watch 'activeImpl', (value) ->
        unless value.code
          value.code = "//Add your implementation (and documentation) here!\n"
        editor.setValue value.code
        scope.activeImpl._dirty = true
      editor.on "change", () ->
        scope.activeImpl._dirty = true

  .service 'playerAuth', PlayerAuth
  .service 'problemServer', ProblemServer
