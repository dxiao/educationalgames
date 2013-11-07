// Generated by CoffeeScript 1.6.3
(function() {
  var createElement, updateTable;

  $(function() {
    return setInterval(updateTable, 2000);
  });

  createElement = function(tag) {
    return $(document.createElement(tag));
  };

  updateTable = function() {
    return $.ajax("monitoring").done(function(data) {
      var datum, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        datum = data[_i];
        _results.push($("tbody").prepend(createElement("tr").append(createElement("td").text(datum[0])).append(createElement("td").text(datum[1])).append(createElement("td").text(datum[2])).append(createElement("td").text(datum[3])).append(createElement("td").text(JSON.stringify(datum[4])))));
      }
      return _results;
    });
  };

}).call(this);

/*
//@ sourceMappingURL=monitoring.map
*/