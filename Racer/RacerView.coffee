Module = {}
window.RacerView = Module

PuzzleSpecs = window.PuzzleSpecs
RacerCode = window.RacerCode

# --------------Utility Code----------------

extend = (obj, mixin) ->
  (obj[name] = method for name, method of mixin)
  obj

copy = (obj) ->
  extend {}, obj

createElement = (tag) ->
  $ document.createElement tag

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
  puzzleSpec = PuzzleSpecs[root.attr "data-puzzleset"]
  if not puzzleSpec?
    throw new Error "Could not find puzzle " + (root.attr "data-puzzleset")
  puzzleSet = new RacerCode.PuzzleSet puzzleSpec
  ordering = new RacerCode.ExecutionOrder puzzleSet
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
      if error instanceof RacerCode.ExecutionError
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
      createElement("td").addClass("process" + cssNum)
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
      .append(printMemoryState(createElement("td"),
        "shared", -1, puzzleSet.memories["shared"].state.values)))

  tbody = createElement("tbody")
  for processName in ordering
    tbody.append(rowTemplate.clone())

  table = createElement("table")
    .addClass("puzzleTable")
    .append(thead).append(tbody).appendTo(root)

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

