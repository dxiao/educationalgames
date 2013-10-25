Module = {}
window.PuzzleSpecs = Module

# --------------Puzzle Specs-------------------

Module.simpleRace =
  name: "Simple Race"
  description: "A simple race condition to demonstrate the need for locks"
  shared:
    balance: 10
  processes:
    A:
      memory: {}
      commands: [
        { type: "Get", local: "tempA", shared: "balance" },
        { type: "Increment", variable: "tempA", increment: 3 },
        { type: "Set", local: "tempA", shared: "balance" }
      ]
    B:
      memory: {}
      commands: [
        { type: "Get", local: "tempB", shared: "balance" },
        { type: "Increment", variable: "tempB", increment: -7 },
        { type: "Set", local: "tempB", shared: "balance" }
      ]

Module.simpleLock =
  name: "Simple Lock"
  description: "A simple modification to fix the race condition in SimpleRace"
  shared:
    balance: 10
    lock: false
  processes:
    A:
      memory: {}
      commands: [
        { type: "Lock", lock: "lock" },
        { type: "Get", local: "tempA", shared: "balance" },
        { type: "Increment", variable: "tempA", increment: 3 },
        { type: "Set", local: "tempA", shared: "balance" }
        { type: "Unlock", lock: "lock" },
      ]
    B:
      memory: {}
      commands: [
        { type: "Lock", lock: "lock" },
        { type: "Get", local: "tempB", shared: "balance" },
        { type: "Increment", variable: "tempB", increment: -7 },
        { type: "Set", local: "tempB", shared: "balance" }
        { type: "Unlock", lock: "lock" },
      ]

Module.deadLock =
  name: "Dead Lock"
  description: "Locks are good, right? So let's add two!"
  shared:
    balance: 10
    lock1: "A"
    lock2: "B"
  processes:
    A:
      memory: {}
      commands: [
        { type: "Lock", lock: "lock1" },
        { type: "Lock", lock: "lock2" },
        { type: "Get", local: "tempA", shared: "balance" },
        { type: "Increment", variable: "tempA", increment: 3 },
        { type: "Set", local: "tempA", shared: "balance" }
        { type: "Unlock", lock: "lock2" },
        { type: "Unlock", lock: "lock1" },
      ]
    B:
      memory: {}
      commands: [
        { type: "Lock", lock: "lock2" },
        { type: "Lock", lock: "lock1" },
        { type: "Get", local: "tempB", shared: "balance" },
        { type: "Increment", variable: "tempB", increment: -7 },
        { type: "Set", local: "tempB", shared: "balance" }
        { type: "Unlock", lock: "lock1" },
        { type: "Unlock", lock: "lock2" },
      ]
