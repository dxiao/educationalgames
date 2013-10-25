$ ->
  setInterval updateTable, 2000

createElement = (tag) ->
  $ document.createElement tag

updateTable = ->
  $.ajax("monitoring").done (data)->
    for datum in data
      $("tbody").prepend(createElement("tr")
        .append(createElement("td").text(datum[0]))
        .append(createElement("td").text(datum[1]))
        .append(createElement("td").text(datum[2]))
        .append(createElement("td").text(datum[3]))
        .append(createElement("td").text(JSON.stringify(datum[4]))))
