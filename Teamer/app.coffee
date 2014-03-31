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

  getView2: () ->
    @http {
      method: 'GET'
      url: '/teamerapi/game/' + @problem + '/getView2'
      params: {id: @id}
    }

  getView3: () ->
    @http {
      method: 'GET'
      url: '/teamerapi/game/' + @problem + '/getView3'
      params: {id: @id}
    }

  getGameInfo: () ->
    @updateConfig()
    @http {
      method: 'GET'
      url: '/teamerapi/game/' + @problem + '/getGameInfo'
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

  submitReview: (review) ->
    @http {
      method: 'POST'
      url: '/teamerapi/game/' + @problem + '/submitReview'
      params: {id: @id}
      data: review.toJson()
    }

angular.module 'teamer', ['ngRoute']
  .config ($routeProvider, $locationProvider) ->
    $routeProvider
      .when '/login', {
        templateUrl: '/teamer/views/login.html'
        controller: 'LoginController'
      }
      .when '/problem/:problem', {
        templateUrl: '/teamer/views/problem.html'
        controller: 'ProblemController'
      }
      .otherwise {
        templateUrl: '/teamer/views/null.html'
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

  .controller 'Prototype', ['$scope',
  ($scope) ->
    $scope.activeImpl = {code:
      "public static String[] anagrams(String word, String[] WORDLIST) {\n"+
      "    return ff3_filter(f3b_deduplicate(f4a_permute(word)), WORDLIST);\n"+
      "}"
    }
    $scope.activeReview = {code:
      "// find all permutations of str and add the given prefix (use \"\")\n"+
      "public static void permute(String str, String prefix) {\n"+
      "    int n = str.length();\n"+
      "    if (n == 0) {\n"+
      "        System.out.println(prefix);\n"+
      "    } else {\n"+
      "        for (int i = 0; i < n; i++) {\n"+
      "            permute(str.substring(0, i) + str.substring(i+1, n), prefix + str.charAt(i));\n"+
      "        }\n"+
      "    }\n"+
      "}"
    }
    $scope.codeEditor = {}
  ]

  .controller 'ProblemController', ['$scope', 'playerAuth', 'problemServer', '$timeout',
  ($scope, playerAuth, server, $timeout) ->
    unless playerAuth.assertLoggedIn()
      return

    $scope.stage = 0
    $scope.player = playerAuth.player

    #startStageOne() ->
    console.log "PROBCTL: start stage one"
    server.joinGame()
    .then (data) ->
      $scope.game = Model.GameInfo.fromJson data.data
      server.getView()
    .then (data) ->
      $scope.view = Model.PlayerView.fromJson data.data, $scope.game
      $scope.view.createImplsForStage 1
      $scope.stage = 1
      if $scope.game.status.stage == 1
        $scope.stageEndTimer = $timeout((() -> endStageOne()), $scope.game.status.endTime - Date.now())
      else
        endStageOne()
    .catch (error) ->
      $scope.error = error

    endStageOne = () ->
      console.log "PROBCTL: end stage one"
      $scope.stage = 1.5
      $stageEndTimer = $timeout((() -> startStageTwo()), 5000)
      $scope.game.status.endTime = Date.now() + 5000

    startStageTwo = () ->
      console.log "PROBCTL: start stage two"
      server.getGameInfo()
      .then (data) ->
        $scope.game.mergeJson data.data
        server.getView2()
      .then (data) ->
        $scope.view2 = Model.PlayerView2.fromJson data.data, $scope.view
        $scope.stage = 2
        if $scope.game.status.stage == 2
          $scope.stageEndTimer = $timeout((() -> endStageTwo()), $scope.game.status.endTime - Date.now())
        else
          endStageTwo()
      .catch (error) ->
        $scope.error = error

    endStageTwo = () ->
      console.log "PROBCTL: end stage two"
      $scope.stage = 2.5
      $stageEndTimer = $timeout((() -> startStageThree()), 5000)
      $scope.game.status.endTime = Date.now() + 5000

    startStageThree = () ->
      console.log "PROBCTL: start stage three"
      server.getGameInfo()
      .then (data) ->
        $scope.game.mergeJson data.data
        server.getView3()
      .then (data) ->
        $scope.view3 = Model.PlayerView3.fromJson data.data, $scope.view2
        $scope.view3.createImplsForProgram()
        $scope.stage = 3
        $scope.activeImpl = null
        $scope.activeReviewSet = null
      .catch (error) ->
        $scope.error = error

    $scope.openImpl = (impl) ->
      console.log "PROBCTL: changing function to " + impl.function.name
      $scope.activeImpl = impl

    $scope.openReview = (reviewSet) ->
      console.log "PROBCTL: changing reviewSet to " + reviewSet.impl.function.name
      $scope.activeReviewSet = reviewSet
      found = false
      for review in reviewSet.reviews
        if review.player.id == $scope.player.id
          $scope.activeReview = review
          console.log "Found previous review"
          found = true
          break
      if not found
        console.log "Making new review"
        $scope.activeReview = new Model.ImplReview reviewSet.impl, $scope.player
        reviewSet.reviews.push $scope.activeReview

    $scope.codeEditor = {}

    $scope.submitImpl = () ->
      $scope.activeImpl.code = $scope.codeEditor.editor.getValue()
      console.log "PROBCTL: submitting implementation for " + $scope.activeImpl.function.name
      server.submitImpl $scope.activeImpl
      .then (data) ->
        $scope.info = data.data
        console.log data.data
        $scope.activeImpl._dirty = false
      .catch (error) ->
        $scope.error = error

    $scope.submitReview = () ->
      console.log "PROBCTL: submitting review for " + $scope.activeReview.impl.function.name
      console.log $scope
      server.submitReview $scope.activeReview
      .then (data) ->
        $scope.activeReview._dirty = false
        $scope.activeReviewSet.mergeJson data.data, $scope.view2.impls, $scope.game.players
        console.log $scope.activeReviewSet
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

  .directive 'functionEditor', () -> {
    restrict: "E"
    link: (scope, element, attrs) ->
      readonly = if attrs.readonly? then "nocursor" else false
      editor = CodeMirror element[0], {
        value: "use strict;"
        mode: "text/x-java"
        lineNumbers: true
        readOnly: readonly
      }
      scope.codeEditor.editor = editor
      scope.$watch attrs.function, (value) ->
        unless value.code
          value.code = "// This page intentionally left blank."
        editor.setValue value.code
        scope.activeImpl._dirty = true
      editor.on "change", () ->
        scope.activeImpl._dirty = true
  }

  .directive 'reviewView', () -> {
    #templateUrl: "teamer/partials/reviewView.html"
    link: (scope, element, attrs) ->
      scope.$watch "review.rating", (value) ->
        if value == "0"
          element.addClass "alert-info"
            .removeClass "alert-success"
            .removeClass "alert-danger"
        else if value == "1"
          element.addClass "alert-success"
            .removeClass "alert-info"
            .removeClass "alert-danger"
        else if value == "-1"
          element.addClass "alert-danger"
            .removeClass "alert-info"
            .removeClass "alert-success"
  }

  .service 'playerAuth', PlayerAuth
  .service 'problemServer', ProblemServer
