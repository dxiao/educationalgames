Module = {}
if module? and module.exports?
  module.exports = Module
  _ = require "../utils.coffee"
  Model = require "../TeamerModel.coffee"

Module.suite = suite = new Model.ProblemSuite "friends"

stageOne = new Model.FunctionFamily "stageOne", 1,
  "For this function, assume that everybody can be represented by a unique name."
stageThree = new Model.FunctionFamily "stageThree", 3,
  "For this program, please disregard the main method - your code will be run" +
  "against test cases, which will assume the existence of this method:<br>" +
  "<pre>public static String[] mostLikelyCouple (String[] friendships)</pre>"

getFriends = new Model.Function "QuestionA", stageOne,
  "Given a list of friendships among some people " +
  "and one person's name, return all friends of that person."

getMutual = new Model.Function "QuestionB", stageOne,
  "Given two groups of people, return everybody in both groups."

getBest = new Model.Function "SuperQuestion", stageThree,
  "Given a list of friendships among some people " +
  "return the pair of with the most mutual friends.<br>" +
  "Friendships are given as an array of Strings, with each string in the array" +
  "a pair of friends' names, separated by a space.<br>" +
  "The function should return a String[] of length 2."

suite.addFamilies stageOne, stageThree
suite.addFunctions getFriends, getMutual, getBest
