less.watch()

Module = {}
window.RaceCode = Module

# --------------Utility Code----------------
extend = (obj, mixin) ->
  (obj[name] = method for name, method of mixin)
  obj

copy = (obj) ->
  extend {}, obj

createElement = (tag) ->
  $ document.createElement tag

# --------------RaceCode Library--------------

# State of memory, binding of names to values
# IMMUTABLE
Module.MemoryState = class MemoryState
  constructor: (values = {}) ->
    @values = copy values
  get: (name) ->
    @values[name]
  # Returns a new MemoryState with the specified variable set to new value
  set: (name, value) ->
    newValues = copy @values
    newValues[name] = value
    new MemoryState newValues

# Reference to current state of memory
# MUTABLE
Module.Memory = class Memory
  constructor: (@startValues = {}) ->
    @reset startValues
  set: (name, value) ->
    @state = @state.set name, value
  get: (name) ->
    @state.get name
  reset: (values=@startValues) ->
    @state = new MemoryState values

# A Process, with a program and memory
# MUTABLE
Module.Process = class Process
  constructor: (@name, @commands, @memory) ->
    @reset()
  reset: ->
    @commandLine = 0
    @memory.reset
  step: ->
    if @commandLine >= @commands.length
      throw new Error "Process " + @name + " has no more instructions!"
    @commands[@commandLine].execute()
    @commandLine++
  # Convenience function to get the current state of memory
  getState: ->
    @memory.state.values

# Reference to a variable in a memory, but not a particular state of that
# variable.
# IMMUTABLE
Module.Variable = class Variable
  constructor: (@name, @memory) ->
  get: ->
    @memory.get @name
  set: (value) ->
    @memory.set @name, value

# Type of comand
# ABSTRACT, IMMUTABLE
Module.CommandType = class CommandType
  # Takes human-readable text of what the command does
  constructor: (@label) ->
  # Executes the function, throws Exception if fails
  execute: ->
    throw new ReferenceError "Execute function not implemented!"

Module.ExecutionError = class ExecutionError extends Error
  constructor: (@message) ->

# Get a variable from shared memory and put it in local
Module.GetShared = class GetShared extends CommandType
  constructor: (@localVar, @sharedVar) ->
    super "Get " + @localVar.name + " from shared." + @sharedVar.name
  execute: ->
    @localVar.set @sharedVar.get()

# Set a variable in shared memory to be value in local
Module.SetShared = class SetShared extends CommandType
  constructor: (@localVar, @sharedVar) ->
    super "Set shared." + @sharedVar.name + " with " + @localVar.name
  execute: ->
    @sharedVar.set @localVar.get()

# Acquire a lock for a process
# NOTE: This is a super simple lock implementation! 
Module.Lock = class Lock extends CommandType
  constructor: (@sharedLockVar, @processName) ->
    super "Acquire lock " + @sharedLockVar.name
  execute: ->
    lockOwner = @sharedLockVar.get()
    if lockOwner == false
      @sharedLockVar.set @processName
    else
      throw new ExecutionError "Can not get lock " + @sharedLockVar.name +
        "; currently held by process " + lockOwner

# Release a lock acquired by the process
# NOTE: This is a super sumple lock implementation! It will release the lock even if
# another part of the process still wants the lock!
Module.Unlock = class Unlock extends CommandType
  constructor: (@sharedLockVar, @processName) ->
    super "Release lock " + @sharedLockVar.name
  execute: ->
    lockOwner = @sharedLockVar.get()
    if lockOwner == @processname
      @sharedLockVar.set false
    else if lockOwner == false
      throw new ExecutionError "Can not release lock not held by any process!"
    else
      throw new ExecutionError "Can not release lock not held by process " + lockOwner

# Increment a variable by x
Module.Increment = class Increment extends CommandType
  constructor: (@variable, @increment) ->
    super "Increment " + @variable.name + " by " + @increment
  execute: ->
    @variable.set @variable.get() + @increment

# --------------Puzzle Operation-------------

ParseCommand = (command, process, memories) ->
  switch command.type
    when "Get"
      new GetShared new Variable(command.local, memories[process]),
        new Variable(command.shared, memories.shared)
    when "Set"
      new SetShared new Variable(command.local, memories[process]),
        new Variable(command.shared, memories.shared)
    when "Increment"
      new Increment new Variable(command.variable, memories[process]),
        command.increment
    when "Lock"
      new Lock new Variable(command.lock, memories.shared), process
    when "Unlock"
      new Unlock new Variable(command.loc, memories.shared), process
    else
      throw new TypeError "Did not recognize command of type " + command.type

# A Race Puzzle, with instantiated Processes and Memory.
# *CONST
Module.PuzzleSet = class PuzzleSet
  constructor: (set) ->
    @shared = new Memory set.shared
    @memories = {shared: @shared}
    @processes = {}
    for name, process of set.processes
      @memories[name] = memory = new Memory process.memory
      commands = (ParseCommand(command, name, @memories) for command in process.commands)
      @processes[name] = new Process(name, commands, memory)
    @finish = set.finish

  reset: ->
    @shared.reset()
    process.reset() for name,process of @processes

  stepProcess: (processName) ->
    @processes[processName].step

  checkFinish: ->
    errors = []
    for memory,finals of @finish
      values = @memories[memory].state.values
      for name, value of finals
        if values[name] != value
          errors.push {memory: memory, expected: value, actual: values[name]}
    errors

# An order in which a puzzle set is executed
# IMMUTABLE
Module.ExecutionOrder = class ExecutionOrder
  constructor: (puzzleOrOrdering) ->
    if puzzleOrOrdering instanceof PuzzleSet
      @ordering = []
      for name,process of puzzleOrOrdering.processes
        for i in [1..process.commands.length]
          @ordering.push name
    else
      @ordering = puzzleOrOrdering


# --------------Puzzle Specs-------------------

Module.simpleRace =
  name: "Simple Race"
  description: "A simple race condition to make sure this works"
  shared:
    balance: 100
  processes:
    A:
      memory: {}
      commands: [
        { type: "Get", local: "atemp", shared: "balance" },
        { type: "Increment", variable: "atemp", increment: 3 },
        { type: "Set", local: "atemp", shared: "balance" }
      ]
    B:
      memory: {}
      commands: [
        { type: "Get", local: "btemp", shared: "balance" },
        { type: "Increment", variable: "btemp", increment: -7 },
        { type: "Set", local: "btemp", shared: "balance" }
      ]
  finish:
    shared:
      balance: 96


# --------------Racer View--------------------

getProcessToCssNumMapping = (processes) ->
  cssMapping = {}
  count = 0
  for name, process of processes
    cssMapping[name] = count
    count++
  cssMapping


# Initialize a Racer Puzzle
Module.initPuzzle = initPuzzle = (root) ->
  puzzleSpec = Module[root.attr "data-puzzleset"]
  if not puzzleSpec?
    throw new Error "Could not find puzzle " + (root.attr "data-puzzleset")
  puzzleSet = new PuzzleSet puzzleSpec
  ordering = new ExecutionOrder puzzleSet
  cssMapping = getProcessToCssNumMapping puzzleSet.processes

  root.data("puzzleSet", puzzleSet)
      .data("ordering", ordering)
      .data("cssMapping", cssMapping)

  createPuzzleTable root, puzzleSet, ordering.ordering, cssMapping

  root.append(createElement("div")
    .attr("data-role", "executionResult"))
  
  if puzzleSpec.finish?
    createPuzzleOutput root, puzzleSet.finish, cssMapping

  fillInCommandsColumn root, puzzleSet.processes, ordering.ordering, cssMapping
  root.append(createElement("button")
    .attr("type", "button")
    .addClass("btn")
    .addClass("btn-primary")
    .text("Execute!")
    .click(do -> () -> executePuzzle root, puzzleSet, ordering, cssMapping))

printMemoryState = (element, name, num, values) ->
  if name != "shared"
    element.addClass("process" + num)
  for field, value of values
    element.append(createElement("div")
      .text(field + ": " + value))
  element

# Note: Update the first column by calling fillInCommands first!
Module.executePuzzle = executePuzzle = (root, puzzleSet, ordering, cssMapping) ->
  puzzleSet.reset()
  processes = puzzleSet.processes
  rows = root.find "tbody tr"
  for row in rows
    cells = $(row).children()
    processName = cells.first().children().first().data("processName")
    try
      processes[processName].step()
    catch error
      if error instanceof ExecutionError
        cells.eq(1+cssMapping[processName])
          .text("HALT: " + error.message)
        break
      else
        throw error
    for processName, cssNum of cssMapping
      printMemoryState cells.eq(1+cssNum), processName, cssNum,
        processes[processName].getState()
    printMemoryState cells.eq(-1), "shared", -1,
      puzzleSet.memories["shared"].state.values

  if puzzleSet.finish?
    finishExecution root, puzzleSet

finishExecution = (root, puzzleSet) ->
  diff = puzzleSet.checkFinish()
  if diff.length > 0
    root.find("[data-role='executionResult']").empty()
      .append(createElement("div")
        .addClass("alert")
        .addClass("alert-success")
        .text("Congratulations! You found an execution order which breaks the program!"))
  else
    root.find("[data-role='executionResult']").empty()
      .append(createElement("div")
        .addClass("alert")
        .addClass("alert-danger")
        .text("This execution order comes out correct. Try ordering them differently!"))

createPuzzleTable = (root, puzzleSet, ordering, cssMapping) ->
  alignedProcessLabels = []
  processStateLabels = []
  processStartStates = []
  rowTemplate = createElement("tr")
    .append(createElement("td").addClass("alignedCode"))
  for processName,cssNum of cssMapping
    alignedProcessLabels[cssNum] = createElement("div")
      .addClass("process" + cssNum).text("Process " + processName)
    processStateLabels[cssNum] = createElement("th")
      .addClass("process" + cssNum).text(processName + " Memory State")
    processStartStates[cssNum] = printMemoryState(
      createElement("td").addClass("process" + cssNum).addClass("code"),
      processName, cssNum, puzzleSet.memories[processName].state.values)
    rowTemplate.append(createElement("td").addClass("process" + cssNum))
  rowTemplate.append(createElement("td"))

  thead = createElement("thead")
    .append(createElement("tr")
      .append(createElement("th")
        .addClass("alignedCode")
        .append(alignedProcessLabels))
      .append(processStateLabels)
      .append(createElement("th")
        .text("Shared Memory State")))
    .append(createElement("tr")
      .append(createElement("td")
        .text("---initial state---").addClass("codeDesc"))
      .append(processStartStates)
      .append(printMemoryState(createElement("td").addClass("code"),
        "shared", -1, puzzleSet.memories["shared"].state.values)))

  tbody = createElement("tbody")
  for processName in ordering
    tbody.append(rowTemplate.clone())

  table = createElement("table")
    .addClass("puzzleTable")
    .append(thead)
    .append(tbody)
    .appendTo(root)

createPuzzleOutput = (root, finish, cssMapping) ->
  root.append(createElement("h4").text("Processes should complete with following memory state:"))
  box = createElement("div")
    .addClass("code")
    .appendTo(root)
  for name,data of finish
    area = createElement("div").text(name + ":").appendTo(box)
    printMemoryState area, name, cssMapping[name], data
    area.children().addClass("indentleft")

fillInCommandsColumn = (root, processes, ordering, cssMapping) ->
  commandCells = root.find "tbody td:first-child"
  commands = {}
  ordering = ordering.slice(0)
  for processName, process of processes
    commands[processName] = process.commands.slice(0)
  for cell in commandCells
    processName = ordering.shift()
    command = commands[processName].shift()
    $(cell).empty()
      .append(createElement("div")
        .addClass("process" + cssMapping[processName])
        .text(command.label)
        .data("processName", processName))


# --------------Ready Function----------------

$ ->
  $("[data-role='racerpuzzle']").each ->
    initPuzzle $ this

