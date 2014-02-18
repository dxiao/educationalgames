Module = {}
if module? and module.exports?
  module.exports = Module
  _ = require "./utils.coffee"
else
  window.TeamerModel = Module
  _ = window.Utils

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

# Problem Submissions

Module.Implementation = class Implementation
  constructor: (@function, @player, @code) ->
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
  toJson: () -> {
    impl: @impl.toShortJson()
    player: @player.id
    rating: @rating
    comment: @comment
  }
  @fromJson: (json, funcToImplList, players) ->
    new ImplReview funcToImplList[json.impl.func][json.impl.player],
      players[json.player], json.rating, json.comment

Module.ImplReviewSet = class ImplReviewSet
  constructor: (@impl, @reviews, @rating) ->
    unless @rating
      @rating = new ImplRating(0, 0)
    unless @reviews
      @reviews = []
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
  toJson: () -> @
  @fromJson: (json) ->
    new ImplRating json.num, json.denom

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
    @impls = @impls.concat (new Implementation(func, @player, "") for func in @functions when func.stage == stage)
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
  toJson: () -> {
    impls: @_makeToJson @impls
    reviews: @_makeToJson @review
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
