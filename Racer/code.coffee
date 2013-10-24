less.watch()

Module = {}
window.RaceCode = Module

RacerView = window.RacerView

# --------------Ready Function----------------

$ ->
  $("[data-role='racerpuzzle']").each ->
    RacerView.initPuzzle $ this

