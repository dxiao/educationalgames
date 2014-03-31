Module = {}
if module? and module.exports?
  module.exports = Module
  _ = require "./utils.coffee"
else
  window.TeamerModel = Module
  _ = window.Utils

implTemplate = """
// Please do not edit the class name!
public class {0} {

    // Your function (and documentation) here:


    static public void main(String args[]) {
        // You can also edit this main method to check your function.
        // It will be run on the server when you click submit.
    }
}
"""

# Problem Description

Module.Function = class Function
  constructor: (@name, @family, @description) ->
    @stage = @family.stage
  toJson: () -> {
    name: @name
    family: @family.name
    description: @description
  }
  @fromJson: (json, families) ->
    new Function json.name, families[json.family], json.description
    

Module.FunctionFamily = class FunctionFamily
  constructor: (@name, @stage, @description) ->
  toJson: () -> @
  @fromJson: (json) ->
    new FunctionFamily json.name, json.stage, json.description

Module.ProblemSuite = class ProblemSuite
  constructor: (@name, @functions = {}) ->
    @functions = {}
    @families = {}
  addFunctions: (functions...) ->
    for func in functions
      @functions[func.name] = func
  addFamilies: (families...) ->
    for fam in families
      @families[fam.name] = fam
  getFunctionsForStage: (stage) ->
    (func for i, func of @functions when func.stage == stage)


# Problem Submissions

Module.Implementation = class Implementation
  constructor: (@function, @player, @code) ->
    unless @code?
      @code = _.format implTemplate, @getClassName()
  getClassName: () ->
    "C" + @function.name + @player.id
  toJson: () -> {
    function: @function.name
    player: @player.id
    code: @code
  }
  toShortJson: () -> {
    func: @function.name
    player: @player.id
  }
  @fromJson: (json, functions, players) ->
    new Implementation functions[json.function], players[json.player], json.code

Module.ImplReview = class ImplReview
  constructor: (@impl, @player, @rating, @comment) ->
    unless @rating? then @rating = 0
    unless @comment? then  @comment = ""
  mergeReview: (review) ->
    @rating = review.rating
    @comment = review.comment
  toJson: () -> {
    impl: @impl.toShortJson()
    player: @player.id
    rating: @rating
    comment: @comment
  }
  @fromJson: (json, funcToImplList, players) ->
    new ImplReview funcToImplList[json.impl.func][json.impl.player],
      players[json.player], parseInt(json.rating), json.comment

Module.ImplReviewSet = class ImplReviewSet
  constructor: (@impl, @reviews, @rating) ->
    unless @rating?
      @rating = new ImplRating(0, 0)
    unless @reviews?
      @reviews = []

  addOrUpdateReview: (newReview) ->
    if newReview.impl != @impl
      console.log "ERROR: review not for this set!"
      return
    for review in @reviews
      if review.player.id == newReview.player.id
        review.mergeReview newReview
        @rating.num += newReview.rating - review.rating
        return review
    @reviews.push newReview
    @rating.addRating newReview.rating
    @updateRating()
    newReview
    
  updateRating: () ->
    @rating.clear()
    for review in @reviews
      @rating.addRating review.rating

  mergeJson: (json, funcToImplList, players) ->
    for reviewJson in json.reviews
      @addOrUpdateReview ImplReview.fromJson reviewJson, funcToImplList, players
    @

  toJson: () -> {
    impl: @impl.toShortJson()
    reviews: (review.toJson() for review in @reviews)
    rating: @rating.toJson()
  }
  @fromJson: (json, funcToImplList, players) ->
    new ImplReviewSet funcToImplList[json.impl.func][json.impl.player],
      (ImplReview.fromJson(review, funcToImplList, players) for review in json.reviews),
      ImplRating.fromJson(json.rating)
 
Module.ImplRating = class ImplRating
  constructor: (@num, @denom) ->
  addRating: (rating) ->
    @num += rating
    @denom += 1
  clear: () ->
    @num = 0
    @denom = 0
  toJson: () -> @
  @fromJson: (json) ->
    new ImplRating parseInt(json.num), parseInt(json.denom)

# Problem State

Module.GameInfo = class GameInfo
  constructor: (@name, @status, @families, @players) ->
  toJson: () -> @
  @fromJson: (json) ->
    players = {}
    for id, player of json.players
      players[id] = Player.fromJson player
    families = {}
    for id, family of json.families
      families[id] = FunctionFamily.fromJson family
    new GameInfo json.name, GameStatus.fromJson(json.status), families, players
  mergeJson: (json) ->
    @status = GameStatus.fromJson(json.status)
    for id, family of json.families
      unless id of @families
        @families[id] = FunctionFamily.fromJson family
    for id, player of json.players
      unless id of @players
        @players[id] = Player.fromJson player

Module.GameStatus = class GameStatus
  constructor: (@stage, @endTime) ->
  toJson: () -> @
  @fromJson: (json) ->
    return new GameStatus json.stage, json.endTime
    
# User Information

Module.Player = class Player
  constructor: (@id, @name) ->
  toJson: () -> @
  @fromJson: (json) ->
    new Player json.id, json.name

Module.PlayerView = class PlayerView
  constructor: (@player, @game) ->
    @functions = []
    @impls = []
  createImplsForStage: (stage) ->
    @impls = @impls.concat (new Implementation(func, @player) for func in @functions when func.stage == stage)
  toJson: () -> {
    player: @player.id,
    game: @game.name,
    functions: (func.toJson() for func in @functions)
    impls: (impl.toJson() for impl in  @impls)
  }
  @fromJson: (json, game) ->
    gamePlayer = new PlayerView game.players[json.player], game
    gamePlayer.functions = (Function.fromJson(func, game.families) for func in json.functions)
    gamePlayer.impls = (Implementation.fromJson(impl, gamePlayer.functions, game.players) for impl in json.impls)
    gamePlayer

Module.PlayerView2 = class PlayerView2
  constructor: (playerView1) ->
    @player = playerView1.player
    @game = playerView1.game
    @functions = {} # id -> func
    @impls = {} # func -> player -> impl
    @reviews = {} # func -> player -> review
    for func in playerView1.functions
      @functions[func.name] = func
      @impls[func.name] = {}
      @reviews[func.name] = {}

  _makeToJson: (mapmapitem) ->
    mapmapjson = {}
    for key, mapitem of mapmapitem
      mapjson = {}
      for keykey, item of mapitem
        mapjson[keykey] = item.toJson()
      mapmapjson[key] = mapjson
    mapmapjson

  getReviewList: () ->
    _.mapToList @reviews, 1

  toJson: () -> {
    impls: @_makeToJson @impls
    reviews: @_makeToJson @reviews
  }
  @fromJson: (json, playerView1) ->
    newView = new PlayerView2 playerView1
    functions = newView.functions
    players = newView.game.players
    newView.impls = json.impls
    for key, mapitem of newView.impls
      for keykey of mapitem
        mapitem[keykey] = Implementation.fromJson mapitem[keykey], functions, players
    newView.reviews = json.reviews
    for key, mapitem of newView.reviews
      for keykey of mapitem
        mapitem[keykey] = ImplReviewSet.fromJson mapitem[keykey], newView.impls, players
    newView

Module.PlayerView3 = class PlayerView3
  constructor: (playerView2, programs) ->
    @player = playerView2.player
    @game = playerView2.game
    @functions = playerView2.functions # id -> func
    @impls = playerView2.impls # func -> player -> impl
    @reviews = playerView2.reviews # func -> player -> review
    @programs = programs
  createImplsForProgram: () ->
    @progImpls = (new Implementation(program, @player, "") for program in @programs)

  _makeToJson: (mapmapitem) ->
    mapmapjson = {}
    for key, mapitem of mapmapitem
      mapjson = {}
      for keykey, item of mapitem
        mapjson[keykey] = item.toJson()
      mapmapjson[key] = mapjson
    mapmapjson

  getReviewList: () ->
    _.mapToList @reviews, 1

  toJson: () ->
    obj = {
      functions: {}
      impls: @_makeToJson @impls
      reviews: @_makeToJson @reviews
      programs: (program.toJson() for program in @programs)
    }
    for id, func in @functions
      obj.functions[id] = func.toJson()
    obj
  @fromJson: (json, playerView2) ->
    programs = (Function.fromJson(program, playerView2.game.families) for program in json.programs)
    newView = new PlayerView3 playerView2, programs
    functions = newView.functions
    players = newView.game.players
    console.log playerView2
    console.log newView
    for key, mapitem of json.impls
      unless key in newView.impls
        newView.impls[key] = {}
      for keykey of mapitem
        if keykey not in newView.impls[key]
          newView.impls[key][keykey] = Implementation.fromJson json.impls[key][keykey], functions, players
    for key, mapitem of json.reviews
      unless key in newView.reviews
        newView.reviews[key] = {}
      for keykey, item of mapitem
        if keykey in newView.reviews[key]
          newView.reviews[key][keykey].mergeJson item, newView.impls, players
        else
          newView.reviews[key][keykey] = ImplReviewSet.fromJson mapitem[keykey], newView.impls, players
    newView
   
