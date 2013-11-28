Module = {}
if module? and module.exports?
  module.exports = Module
  _ = require "./Utils.coffee"
else
  window.DebuggerModel = Module
  _ = window.Utils


LINE_NUM_WIDTH = 3

Module.Line = class Line
  constructor: (@line, @num) ->

  isNum: (num) ->
    return num == @num

  toString: ->
    return _.pad(@num, LINE_NUM_WIDTH) + ": " + @line

  toJson: ->
    return {line: @line, num: @num}
  @fromJson: (json) ->
    return new Line json.line, json.num

# [num, endNum)
Module.EmptyLineBlock = class EmptyLineBlock extends Line
  constructor: (@num, @endnum) ->
    _.assert @num <= @endnum, "Empty Line invariant: " + @num + "-" + @endnum

  isNum: (num) ->
    return @num <= num < @endnum

  splitAroundOn: (line) ->
    _.assert @isNum(line.num), "Split must get line between " + @num + "-" + @endnum
    ret = [line]
    num = line.num
    if num+1 < @endnum
      ret.append new EmptyLineBlock @num+1, @endnum
    if @num < num
      ret.append new EmptyLineBlock @num, num
    return ret

  toString: ->
    return "###" + ": Lines " +
      @num + " to " + (@endnum-1) + " not yet known."

  toJson: ->
    return {num: @num, endnum: @endnum}
  @fromJson: (json) ->
    return new EmptyLineBlock json.num, json.endnum

Module.ProgramView = class ProgramView
  constructor: (@numLines, @lines) ->
    @lines = [new EmptyLineBlock 0, @numLines] if not @lines?

  findLine: (num) ->
    for curLine, i in @lines
      if curLine.isNum num
        return i
    return -1

  getLine: (num) ->
    index = @findLine num
    unless index == -1
      return @lines[index]
    else
      return null

  setLine: (line) ->
    _.assert line.num < @numLines, "Line number specified is out of program bounds"
    num = line.num
    index = @getLine num
    if index == -1
      @lines.append line
    curLine = @lines[index]
    if curLine instanceof EmptyLineBlock
      @lines[index..index] = curLine.splitAround line
    else
      @lines[index] = line
      
  setLines: (lines) ->
    for line in lines
      @setline line
