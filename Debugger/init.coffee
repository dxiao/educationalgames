ClassView = window.ClassView

# --------------Ready Function----------------

$ ->
  $("[data-role='classmodel']").each ->
    ClassView.initView $ this

