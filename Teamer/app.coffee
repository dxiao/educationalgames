Model = window.TeamerModel

class PlayerAuth
  @$inject = ['$http']

  constructor: ($http) ->
    @http = $http

  submitLogin: (name, callback) ->
    @http {
      method: 'GET',
      url: '/teamerapi/login'
      params: {name: name}
    }
    .success (data, status) =>
      @_setPlayer data, name
      callback @player, null
    .error (data, status) ->
      callback null, data

  _setPlayer: (id, name) ->
    @player = new Model.Player id, name

class ProblemServer
  @$inject = ['$http', '$location', 'playerAuth']

  constructor: ($http, $location, playerAuth) ->
    @http = $http
    @player = playerAuth.player
    @problem = $location.path().split("/")[2]

  getFunctions: (callback) ->
    @http {
      method: 'GET'
      url: '/teamerapi/problem/' + @problem + '/getFunctions'
      params: {id: @player.id}
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
    $scope.user = 'blah'
    $scope.submitName = () ->
      $scope.loginError = false
      $scope.id = playerAuth.submitLogin name, (player, error) ->
        if player
          $location.path("")
        else
          $scope.loginError = error
  ]

  .controller 'InitController', ['$location', 'playerAuth',
  ($location, playerAuth) ->
    if playerAuth.player
      console.log "INIT: player detected, redirecting to problem"
      $location.path "/problem/sql/phase1"
    else
      console.log "INIT: no player found, redirecting to login"
      $location.path "/login"
  ]

  .controller 'ProblemController', ['$scope', '$location', 'problemServer',
  ($scope, $location, server) ->
    server.getFunctions (data, error) ->
      $scope.problems = data
  ]

  .service 'playerAuth', PlayerAuth
  .service 'problemServer', ProblemServer
