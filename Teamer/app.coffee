
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
  .controller 'LoginController', ($scope) ->
    $scope.user = 'blah'
