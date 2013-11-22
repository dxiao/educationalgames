Module = {}
window.ProgramModel = Module
ProgramModel = window.ProgramModel

# --------------Utility Code----------------

extend = (obj, mixin) ->
  (obj[name] = method for name, method of mixin)
  obj

copy = (obj) ->
  extend {}, obj

newElement = (tag) ->
  $ document.createElement tag

assert = (condition, message) ->
  unless condition
    throw new Error "ASSERT: " + message

pad = (str, num, char) ->
  char = " " if not char
  return str + (char * (num - str.length if num < str.length else 0))

# --------------Class View------------------

LINE_NUM_WIDTH = 3

ProgramModel.Line = class Line
  constructor: (@line, @num) ->

  isNum: (num) ->
    return num == @num

  toString: ->
    return pad(@num, LINE_NUM_WIDTH) + ": " + @line

# [num, endNum)
ProgramModel.EmptyLineBlock = class EmptyLineBlock extends Line
  constructor: (@num, @endnum) ->
    assert @num >= @endnum, "Empty Line invariant: " + @num + "-" + @endnum

  isNum: (num) ->
    return @num <= num < @endnum

  splitAroundOn: (line) ->
    assert isNum(line.num), "Split must get line between " + @num + "-" + @endnum
    ret = [line]
    num = line.num
    if num+1 < @endnum
      ret.append new EmptyLineBlock @num+1, @endnum
    if @num < num
      ret.append new EmptyLineBlock @num, num
    return ret

  toString: ->
    return "###: Lines " + @num + " to " + (@endnum-1) + " not yet known."

ProgramModel.ProgramView = class ProgramView
  constructor: (@numLines, @lines) ->
    @lines = [new EmptyLineBlock 0, @numLines] if not @lines?

  findLine: (num) ->
    for curLine, i in @lines
      if curLine.isNum num
        return i
    return -1

  getLine: (num) ->
    index = findLine num
    unless index == -1
      return @lines[index]
    else
      return null

  setLine: (line) ->
    assert line.num < @numLines, "Line number specified is out of program bounds"
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

