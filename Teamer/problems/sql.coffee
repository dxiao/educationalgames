Module = {}
if module? and module.exports?
  module.exports = Module
  _ = require "./Utils.coffee"

Model = require "../TeamerModel.coffee"

treeInsert = new Model.Problem "insert",
  "Given an element and its index, insert the element into the tree"

treeFindSize = new Model.Problem "findSize",
  "Find the current size of the tree rooted at the given node"

#treeGetLargest = new Model.Problem "getLargest",
#  "Find the largest element of the tree rooted at the given node"

treeInOrder = new Model.Problem "inOrder",
  "Return a list of elements in the tree in order of ascending index"

treeProblems = new Model.ProblemFamily "tree", 1,
  "For these problems, assume an object called a TreeNode, defined so:\n" +
  "  class TreeNode:\n" +
  "    index: index of the value stored at this node.\n" +
  "    value: datum stored at this node.\n" +
  "    left: a TreeNode subnode whose index and sub-TreeNodes' indices " +
  "are all smaller than this node's index.\n" +
  "    right: a TreeNode subnode whose index and sub-TreeNodes' indices " +
  "are all larger than this node's index.\n"
treeProblems.addProblems treeInsert, treeFindSize, treeInOrder

parseSelect = new Model.Problem "parseSelect",
  "Given a string, determine if it is a SELECT command and if so, the range " +
  "of indices which it is trying to select"

parseInsert = new Model.Problem "parseInsert",
  "Given a string, determine if it is an INSERT command and if so, the index " +
  "and value which is asking to be inserted"

printValues = new Model.Problem "printValues",
  "Given a list of indeces and values, print the indices and values like so:\n" +
  "  1 bcd\n" +
  "  3 foobar\n" +
  "  11 alice"

ioProblems = new Model.ProblemFamily "io", 1,
  "For these problems, assume you are writing an input/output module for a " +
  "small in-house database program. Commands are given to the module in " +
  "the form of SQL-like commands."
ioProblems.addProblems parseSelect, parseInsert, printValues

# phase 2
treeNthLargest = new Model.Problem "nthLargest",
  "Return the n largest elements in the given tree"

sqlServer = new Model.Problem "sqlserver",
  "Given a SQL-like command in the following forms and a tree-based database, " +
  "do the command against the database, and return the result."

finalProblems = new Model.ProblemFamily "final", 2,
  "For these problems, you can use any submissions to the previous rounds you " +
  "want, as long as you give proper credit."
finalProblems.addProblems treeNthLargest, sqlServer

suite = new Model.ProblemSuite "sqlSuite"
suite.addFamilies treeProblems, ioProblems, finalProblems
Module.suite = suite
