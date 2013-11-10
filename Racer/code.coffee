RacerView = window.RacerView

# --------------Ready Function----------------

$ ->
  $("[data-role='racerpuzzle']").each ->
    RacerView.initPuzzle $ this

