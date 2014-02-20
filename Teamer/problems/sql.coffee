Module = {}
if module? and module.exports?
  module.exports = Module
  _ = require "../utils.coffee"
  Model = require "../TeamerModel.coffee"

Module.suite = suite = new Model.ProblemSuite "sqlSuite"

treeFunctions = new Model.FunctionFamily "tree", 1,
  "For this problem, assume binary tree class called TreeNode, defined so:\n" +
  "  class TreeNode:\n" +
  "    index: index of the value stored at this node.\n" +
  "    value: datum stored at this node.\n" +
  "    left: a TreeNode subnode whose index and sub-TreeNodes' indices " +
  "are all smaller than this node's index.\n" +
  "    right: a TreeNode subnode whose index and sub-TreeNodes' indices " +
  "are all larger than this node's index.\n"

treeInsert = new Model.Function "insert", treeFunctions,
  "Given a tree, an element and index, insert the element into the tree using the specified index"

treeFindSize = new Model.Function "findSize", treeFunctions,
  "Find the current size of the tree rooted at the given node"

#treeGetLargest = new Model.Problem "getLargest",
#  "Find the largest element of the tree rooted at the given node"

treeInOrder = new Model.Function "inOrder", treeFunctions,
  "Return a list of elements in the tree in order of ascending index"

ioProblems = new Model.FunctionFamily "io", 1,
  "For this problem, assume you are writing an input/output module for a " +
  "small in-house database program.\n Commands are given to the module in " +
  "the form of SQL-like commands."

parseSelect = new Model.Function "parseSelect", ioProblems,
  "Given a string, determine if it is a SELECT command and if so, the range " +
  "of indices which it is trying to select"

parseInsert = new Model.Function "parseInsert", ioProblems,
  "Given a string, determine if it is an INSERT command and if so, the index " +
  "and value which is asking to be inserted"

printValues = new Model.Function "printValues", ioProblems,
  "Given a list of numbers and values, print the numbers and values in a pretty way.\n" +
  "One way might print the values like so:\n" +
  "  1  bcd\n" +
  "  3  foobar\n" +
  "  11 alice"

# phase 2

finalProblems = new Model.FunctionFamily "final", 2,
  "For these problems, you can use any submissions to the previous rounds you " +
  "want, as long as you give proper credit."

treeNthLargest = new Model.Function "nthLargest", finalProblems,
  "Return the n largest elements in the given tree"

sqlServer = new Model.Function "sqlserver", finalProblems,
  "Given a SQL-like command in the following forms and a tree-based database, " +
  "do the command against the database, and return the result."

suite.addFamilies treeFunctions, ioProblems, finalProblems
suite.addFunctions treeInOrder, treeFindSize, treeInsert, parseInsert, parseSelect, printValues,
  treeNthLargest, sqlServer
