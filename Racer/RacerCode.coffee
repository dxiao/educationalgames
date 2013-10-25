Module = {}
window.RacerCode = Module

# --------------Utility Code----------------

extend = (obj, mixin) ->
  (obj[name] = method for name, method of mixin)
  obj

copy = (obj) ->
  extend {}, obj

# --------------Model Classes---------------

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
    @memory.reset()
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
    @name = set.name
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
# MUTABLE
Module.ExecutionOrder = class ExecutionOrder
  constructor: (puzzleOrOrdering) ->
    if puzzleOrOrdering instanceof PuzzleSet
      @ordering = []
      for name,process of puzzleOrOrdering.processes
        for i in [1..process.commands.length]
          @ordering.push name
    else
      @ordering = puzzleOrOrdering
  getIndexFromCommandOrder: (pos) ->
    index = 0
    process = pos.process
    order = pos.order
    for i in [@ordering.length-1..0] by -1
      if @ordering[i] == process
        order--
        if order == -1
          console.log "index " + i
          return i
    throw new Error "Could not find index for " + process + " order " + order
  tryCommandMove: (oldPos, newPos) ->
    process = oldPos.process
    oldIndex = @getIndexFromCommandOrder oldPos
    newIndex = @getIndexFromCommandOrder newPos
    if oldIndex == newIndex
      return true
    incr = if oldIndex > newIndex then -1 else 1
    length = @ordering.length
    testIndex = oldIndex
    while @ordering[testIndex] == process
      testIndex += incr
      if testIndex < 0 or testIndex >= length
        return false
    if testIndex < 0 or testIndex >= length
      return false
    console.log "swapping " + oldIndex + "," + testIndex
    @ordering[oldIndex] = @ordering[testIndex]
    @ordering[testIndex] = process
    return true
