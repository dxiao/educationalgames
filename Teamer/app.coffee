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
    @getProblem = () -> $location.path().split("/")[2]

  getFunctions: (callback) ->
    @http {
      method: 'GET'
      url: '/teamerapi/problem/' + @getProblem() + '/getFunctions'
      params: {id: @playerAuth.player.id}
    }
    .success (data, status) =>
      callback data, null
    .error (data, status) ->
      callback null, data

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
          $location.path("")
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

    $scope.ProblemStage = "Stage 1"
    $scope.ProblemName = server.getProblem()
    server.getFunctions (data, error) ->
      $scope.functions = data
  ]

  .service 'playerAuth', PlayerAuth
  .service 'problemServer', ProblemServer
