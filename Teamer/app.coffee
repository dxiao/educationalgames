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

  joinGame: () ->
    @updateConfig()
    @http {
      method: 'GET'
      url: '/teamerapi/game/' + @problem + '/joinGame'
      params: {id: @id}
    }

angular.module 'teamer', ['ngRoute']
  .config ($routeProvider, $locationProvider) ->
    $routeProvider
      .when '/login', {
        templateUrl: 'teamer/views/login.html'
        controller: 'LoginController'
      }
      .when '/problem/:problem/:stage', {
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
      $location.path "/problem/sql/phase1"
  ]

  .controller 'ProblemController', ['$scope', 'playerAuth', 'problemServer',
  ($scope, playerAuth, server) ->
    unless playerAuth.assertLoggedIn()
      return

    server.joinGame().then (data) ->
      $scope.info = Model.GameInfo.fromJson data.data
      server.getFunctions()
    .then (data) ->
      $scope.functions = data.data
    .catch (error) ->
      $scope.error = error

    $scope.openFunction = (func) ->
      console.log "PROBCTL: changing function to " + func.name
      $scope.currentFunction = func
      $scope.currentFamily = $scope.info.families[func.family]
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

  .service 'playerAuth', PlayerAuth
  .service 'problemServer', ProblemServer
