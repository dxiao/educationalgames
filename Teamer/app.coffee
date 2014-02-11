
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

angular.module 'teamer', ['ngRoute']
  .config ($routeProvider, $locationProvider) ->
    $routeProvider
      .when '/login', {
        templateUrl: 'teamer/views/login.html',
        controller: 'LoginController'
      }
      .otherwise {
        templateUrl: 'teamer/views/null.html'
      }
  .controller 'LoginController', ['$scope', 'playerAuth', ($scope, playerAuth) ->
    $scope.user = 'blah'
    $scope.submitName = () ->
      $scope.id = playerAuth.submitLogin name
        .success (data, status) ->
          console.log "Success! " + data
        .error (data, status) ->
          console.log "Error! " + data
  ]
  .service 'playerAuth', PlayerAuth
