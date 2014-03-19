// Generated by CoffeeScript 1.7.1
(function() {
  var Function, FunctionFamily, GameInfo, GameStatus, ImplRating, ImplReview, ImplReviewSet, Implementation, Module, Player, PlayerView, PlayerView2, PlayerView3, ProblemSuite, _,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Module = {};

  if ((typeof module !== "undefined" && module !== null) && (module.exports != null)) {
    module.exports = Module;
    _ = require("./utils.coffee");
  } else {
    window.TeamerModel = Module;
    _ = window.Utils;
  }

  Module.Function = Function = (function() {
    function Function(name, family, description) {
      this.name = name;
      this.family = family;
      this.description = description;
      this.stage = this.family.stage;
    }

    Function.prototype.toJson = function() {
      return {
        name: this.name,
        family: this.family.name,
        description: this.description
      };
    };

    Function.fromJson = function(json, families) {
      return new Function(json.name, families[json.family], json.description);
    };

    return Function;

  })();

  Module.FunctionFamily = FunctionFamily = (function() {
    function FunctionFamily(name, stage, description) {
      this.name = name;
      this.stage = stage;
      this.description = description;
    }

    FunctionFamily.prototype.toJson = function() {
      return this;
    };

    FunctionFamily.fromJson = function(json) {
      return new FunctionFamily(json.name, json.stage, json.description);
    };

    return FunctionFamily;

  })();

  Module.ProblemSuite = ProblemSuite = (function() {
    function ProblemSuite(name, functions) {
      this.name = name;
      this.functions = functions != null ? functions : {};
      this.functions = {};
      this.families = {};
    }

    ProblemSuite.prototype.addFunctions = function() {
      var func, functions, _i, _len, _results;
      functions = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _results = [];
      for (_i = 0, _len = functions.length; _i < _len; _i++) {
        func = functions[_i];
        _results.push(this.functions[func.name] = func);
      }
      return _results;
    };

    ProblemSuite.prototype.addFamilies = function() {
      var fam, families, _i, _len, _results;
      families = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _results = [];
      for (_i = 0, _len = families.length; _i < _len; _i++) {
        fam = families[_i];
        _results.push(this.families[fam.name] = fam);
      }
      return _results;
    };

    ProblemSuite.prototype.getFunctionsForStage = function(stage) {
      var func, i, _ref, _results;
      _ref = this.functions;
      _results = [];
      for (i in _ref) {
        func = _ref[i];
        if (func.stage === stage) {
          _results.push(func);
        }
      }
      return _results;
    };

    return ProblemSuite;

  })();

  Module.Implementation = Implementation = (function() {
    function Implementation(_function, player, code) {
      this["function"] = _function;
      this.player = player;
      this.code = code;
    }

    Implementation.prototype.toJson = function() {
      return {
        "function": this["function"].name,
        player: this.player.id,
        code: this.code
      };
    };

    Implementation.prototype.toShortJson = function() {
      return {
        func: this["function"].name,
        player: this.player.id
      };
    };

    Implementation.fromJson = function(json, functions, players) {
      return new Implementation(functions[json["function"]], players[json.player], json.code);
    };

    return Implementation;

  })();

  Module.ImplReview = ImplReview = (function() {
    function ImplReview(impl, player, rating, comment) {
      this.impl = impl;
      this.player = player;
      this.rating = rating;
      this.comment = comment;
      if (this.rating == null) {
        this.rating = 0;
      }
      if (this.comment == null) {
        this.comment = "";
      }
    }

    ImplReview.prototype.mergeReview = function(review) {
      this.rating = review.rating;
      return this.comment = review.comment;
    };

    ImplReview.prototype.toJson = function() {
      return {
        impl: this.impl.toShortJson(),
        player: this.player.id,
        rating: this.rating,
        comment: this.comment
      };
    };

    ImplReview.fromJson = function(json, funcToImplList, players) {
      return new ImplReview(funcToImplList[json.impl.func][json.impl.player], players[json.player], parseInt(json.rating), json.comment);
    };

    return ImplReview;

  })();

  Module.ImplReviewSet = ImplReviewSet = (function() {
    function ImplReviewSet(impl, reviews, rating) {
      this.impl = impl;
      this.reviews = reviews;
      this.rating = rating;
      if (this.rating == null) {
        this.rating = new ImplRating(0, 0);
      }
      if (this.reviews == null) {
        this.reviews = [];
      }
    }

    ImplReviewSet.prototype.addOrUpdateReview = function(newReview) {
      var review, _i, _len, _ref;
      if (newReview.impl !== this.impl) {
        console.log("ERROR: review not for this set!");
        return;
      }
      _ref = this.reviews;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        review = _ref[_i];
        if (review.player.id === newReview.player.id) {
          review.mergeReview(newReview);
          this.rating.num += newReview.rating - review.rating;
          return review;
        }
      }
      this.reviews.push(newReview);
      this.rating.addRating(newReview.rating);
      this.updateRating();
      return newReview;
    };

    ImplReviewSet.prototype.updateRating = function() {
      var review, _i, _len, _ref, _results;
      this.rating.clear();
      _ref = this.reviews;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        review = _ref[_i];
        _results.push(this.rating.addRating(review.rating));
      }
      return _results;
    };

    ImplReviewSet.prototype.mergeJson = function(json, funcToImplList, players) {
      var reviewJson, _i, _len, _ref;
      _ref = json.reviews;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        reviewJson = _ref[_i];
        this.addOrUpdateReview(ImplReview.fromJson(reviewJson, funcToImplList, players));
      }
      return this;
    };

    ImplReviewSet.prototype.toJson = function() {
      var review;
      return {
        impl: this.impl.toShortJson(),
        reviews: (function() {
          var _i, _len, _ref, _results;
          _ref = this.reviews;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            review = _ref[_i];
            _results.push(review.toJson());
          }
          return _results;
        }).call(this),
        rating: this.rating.toJson()
      };
    };

    ImplReviewSet.fromJson = function(json, funcToImplList, players) {
      var review;
      return new ImplReviewSet(funcToImplList[json.impl.func][json.impl.player], (function() {
        var _i, _len, _ref, _results;
        _ref = json.reviews;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          review = _ref[_i];
          _results.push(ImplReview.fromJson(review, funcToImplList, players));
        }
        return _results;
      })(), ImplRating.fromJson(json.rating));
    };

    return ImplReviewSet;

  })();

  Module.ImplRating = ImplRating = (function() {
    function ImplRating(num, denom) {
      this.num = num;
      this.denom = denom;
    }

    ImplRating.prototype.addRating = function(rating) {
      this.num += rating;
      return this.denom += 1;
    };

    ImplRating.prototype.clear = function() {
      this.num = 0;
      return this.denom = 0;
    };

    ImplRating.prototype.toJson = function() {
      return this;
    };

    ImplRating.fromJson = function(json) {
      return new ImplRating(parseInt(json.num), parseInt(json.denom));
    };

    return ImplRating;

  })();

  Module.GameInfo = GameInfo = (function() {
    function GameInfo(name, status, families, players) {
      this.name = name;
      this.status = status;
      this.families = families;
      this.players = players;
    }

    GameInfo.prototype.toJson = function() {
      return this;
    };

    GameInfo.fromJson = function(json) {
      var families, family, id, player, players, _ref, _ref1;
      players = {};
      _ref = json.players;
      for (id in _ref) {
        player = _ref[id];
        players[id] = Player.fromJson(player);
      }
      families = {};
      _ref1 = json.families;
      for (id in _ref1) {
        family = _ref1[id];
        families[id] = FunctionFamily.fromJson(family);
      }
      return new GameInfo(json.name, GameStatus.fromJson(json.status), families, players);
    };

    GameInfo.prototype.mergeJson = function(json) {
      var family, id, player, _ref, _ref1, _results;
      this.status = GameStatus.fromJson(json.status);
      _ref = json.families;
      for (id in _ref) {
        family = _ref[id];
        if (!(id in this.families)) {
          this.families[id] = FunctionFamily.fromJson(family);
        }
      }
      _ref1 = json.players;
      _results = [];
      for (id in _ref1) {
        player = _ref1[id];
        if (!(id in this.players)) {
          _results.push(this.players[id] = Player.fromJson(player));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return GameInfo;

  })();

  Module.GameStatus = GameStatus = (function() {
    function GameStatus(stage, endTime) {
      this.stage = stage;
      this.endTime = endTime;
    }

    GameStatus.prototype.toJson = function() {
      return this;
    };

    GameStatus.fromJson = function(json) {
      return new GameStatus(json.stage, json.endTime);
    };

    return GameStatus;

  })();

  Module.Player = Player = (function() {
    function Player(id, name) {
      this.id = id;
      this.name = name;
    }

    Player.prototype.toJson = function() {
      return this;
    };

    Player.fromJson = function(json) {
      return new Player(json.id, json.name);
    };

    return Player;

  })();

  Module.PlayerView = PlayerView = (function() {
    function PlayerView(player, game) {
      this.player = player;
      this.game = game;
      this.functions = [];
      this.impls = [];
    }

    PlayerView.prototype.createImplsForStage = function(stage) {
      var func;
      return this.impls = this.impls.concat((function() {
        var _i, _len, _ref, _results;
        _ref = this.functions;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          func = _ref[_i];
          if (func.stage === stage) {
            _results.push(new Implementation(func, this.player, ""));
          }
        }
        return _results;
      }).call(this));
    };

    PlayerView.prototype.toJson = function() {
      var func, impl;
      return {
        player: this.player.id,
        game: this.game.name,
        functions: (function() {
          var _i, _len, _ref, _results;
          _ref = this.functions;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            func = _ref[_i];
            _results.push(func.toJson());
          }
          return _results;
        }).call(this),
        impls: (function() {
          var _i, _len, _ref, _results;
          _ref = this.impls;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            impl = _ref[_i];
            _results.push(impl.toJson());
          }
          return _results;
        }).call(this)
      };
    };

    PlayerView.fromJson = function(json, game) {
      var func, gamePlayer, impl;
      gamePlayer = new PlayerView(game.players[json.player], game);
      gamePlayer.functions = (function() {
        var _i, _len, _ref, _results;
        _ref = json.functions;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          func = _ref[_i];
          _results.push(Function.fromJson(func, game.families));
        }
        return _results;
      })();
      gamePlayer.impls = (function() {
        var _i, _len, _ref, _results;
        _ref = json.impls;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          impl = _ref[_i];
          _results.push(Implementation.fromJson(impl, gamePlayer.functions, game.players));
        }
        return _results;
      })();
      return gamePlayer;
    };

    return PlayerView;

  })();

  Module.PlayerView2 = PlayerView2 = (function() {
    function PlayerView2(playerView1) {
      var func, _i, _len, _ref;
      this.player = playerView1.player;
      this.game = playerView1.game;
      this.functions = {};
      this.impls = {};
      this.reviews = {};
      _ref = playerView1.functions;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        func = _ref[_i];
        this.functions[func.name] = func;
        this.impls[func.name] = {};
        this.reviews[func.name] = {};
      }
    }

    PlayerView2.prototype._makeToJson = function(mapmapitem) {
      var item, key, keykey, mapitem, mapjson, mapmapjson;
      mapmapjson = {};
      for (key in mapmapitem) {
        mapitem = mapmapitem[key];
        mapjson = {};
        for (keykey in mapitem) {
          item = mapitem[keykey];
          mapjson[keykey] = item.toJson();
        }
        mapmapjson[key] = mapjson;
      }
      return mapmapjson;
    };

    PlayerView2.prototype.getReviewList = function() {
      return _.mapToList(this.reviews, 1);
    };

    PlayerView2.prototype.toJson = function() {
      return {
        impls: this._makeToJson(this.impls),
        reviews: this._makeToJson(this.reviews)
      };
    };

    PlayerView2.fromJson = function(json, playerView1) {
      var functions, key, keykey, mapitem, newView, players, _ref, _ref1;
      newView = new PlayerView2(playerView1);
      functions = newView.functions;
      players = newView.game.players;
      newView.impls = json.impls;
      _ref = newView.impls;
      for (key in _ref) {
        mapitem = _ref[key];
        for (keykey in mapitem) {
          mapitem[keykey] = Implementation.fromJson(mapitem[keykey], functions, players);
        }
      }
      newView.reviews = json.reviews;
      _ref1 = newView.reviews;
      for (key in _ref1) {
        mapitem = _ref1[key];
        for (keykey in mapitem) {
          mapitem[keykey] = ImplReviewSet.fromJson(mapitem[keykey], newView.impls, players);
        }
      }
      return newView;
    };

    return PlayerView2;

  })();

  Module.PlayerView3 = PlayerView3 = (function() {
    function PlayerView3(playerView2, program) {
      this.player = playerView2.player;
      this.game = playerView2.game;
      this.functions = playerView2.functions;
      this.impls = playerView2.impls;
      this.reviews = playerView2.reviews;
      this.program = program;
    }

    PlayerView3.prototype.createImplForProgram = function() {
      return this.progImpl = new Implementation(this.program, this.player, "");
    };

    PlayerView3.prototype._makeToJson = function(mapmapitem) {
      var item, key, keykey, mapitem, mapjson, mapmapjson;
      mapmapjson = {};
      for (key in mapmapitem) {
        mapitem = mapmapitem[key];
        mapjson = {};
        for (keykey in mapitem) {
          item = mapitem[keykey];
          mapjson[keykey] = item.toJson();
        }
        mapmapjson[key] = mapjson;
      }
      return mapmapjson;
    };

    PlayerView3.prototype.getReviewList = function() {
      return _.mapToList(this.reviews, 1);
    };

    PlayerView3.prototype.toJson = function() {
      var func, id, obj, _i, _len, _ref;
      obj = {
        functions: {},
        impls: this._makeToJson(this.impls),
        reviews: this._makeToJson(this.reviews),
        program: this.program.toJson()
      };
      _ref = this.functions;
      for (func = _i = 0, _len = _ref.length; _i < _len; func = ++_i) {
        id = _ref[func];
        obj.functions[id] = func.toJson();
      }
      return obj;
    };

    PlayerView3.fromJson = function(json, playerView2) {
      var functions, item, key, keykey, mapitem, newView, players, program, _ref, _ref1;
      program = Function.fromJson(json.program);
      newView = new PlayerView3(playerView2, program);
      functions = newView.functions;
      players = newView.game.players;
      _ref = json.impls;
      for (key in _ref) {
        mapitem = _ref[key];
        if (__indexOf.call(newView.impls, key) < 0) {
          newView.impls[key] = {};
        }
        for (keykey in mapitem) {
          if (__indexOf.call(newView.impls[key], keykey) < 0) {
            newView.impls[key][keykey] = Implementation.fromJson(json.impls[key][keykey], functions, players);
          }
        }
      }
      _ref1 = json.reviews;
      for (key in _ref1) {
        mapitem = _ref1[key];
        if (__indexOf.call(newView.reviews, key) < 0) {
          newView.reviews[key] = {};
        }
        for (keykey in mapitem) {
          item = mapitem[keykey];
          if (__indexOf.call(newView.reviews[key], keykey) >= 0) {
            newView[key][keykey].mergeJson(item, newView.impls, players);
          } else {
            newView[key][keykey] = ImplReviewSet.fromJson(mapitem[keykey], newView.impls, players);
          }
        }
      }
      return newView;
    };

    return PlayerView3;

  })();

}).call(this);

//# sourceMappingURL=TeamerModel.map
