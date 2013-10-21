function createElement (tag) {
  return $(document.createElement(tag));
}

var passedText = [
  "It's Working!",
  "Level Up!",
  "Nice!",
  "Keep Going!",
  "Good, but not done yet!",
  "Too easy, eh?",
];

var failedText = [
  "Not quite...",
  "Try Again...",
  "Once more, with feeling!",
  "Merp.",
  ":/",
  "Keep trying!",
  "Hmmm...",
  "Didn't work...",
  "Something didn't work...",
];

var finishedText = [
  "It worked! Whoo!",
  "Good job!",
  "Now you're thinking with regex!"
];

var testCases = [
  ["6.005", "6.005"],
  ["6.01", "6.01"],
  ["2.009", "2.009"],
  ["14.01", "14.01"],
  ["6.", null],
  [".001", null],
  ["6.0000000001", null],
  ["6.00:)1", null],
  ["", null],
  ["6.S064", "6.S064"],
  ["6.1", null],
  ["6-3", null],
  ["6005", null],
  ["0.000", null],
  ["21H.421", "21H.421"],
  ["45.000", null],
  ["6.005x", "6.005x"],
  ["ART.101", null],
  ["CMS.611", "CMS.611"],
  ["6.UAT", "6.UAT"],
  ["19.NOM", null],
];
var curTest = 0;

$(function () {
  updateCurrentTests("noanimation");
  $("#regex-submit").click(runRegex);
  $("#regex-guess")
    .keypress(handleRegexEnter)
    .focus();
});

function getMatchText(text) {
  return text ? text : "nothing"
}

function exerciseFinished() {
  var regexGoal = $("#regex-curtest");
  regexGoal.children().slideUp();
  createElement("div")
    .append(createElement("p")
      .text("Congratulations! You got it!"))
    .append(createElement("p")
      .html("Now try <a href='http://ex-parrot.com/~pdw/Mail-RFC822-Address.html'>email</a>!"))
    .hide().appendTo(regexGoal).slideDown();
}

function updateCurrentTests(animation) {
  var regexGoal = $("#regex-curtest"),
      curLength = regexGoal.children().length,
      spec;
  if (curTest == testCases.length) {
    exerciseFinished();
  } else {
    for (var i = curLength; i <= curTest; i++) {
      spec = createElement("p")
        .text(testCases[i][0] + " should match " + getMatchText(testCases[i][1]));

      if (animation != "noanimation") {
        spec.hide().prependTo(regexGoal).slideDown();
      } else {
        spec.prependTo(regexGoal)
      }
    }
  }
}

function updateProgressBars(passing, failing, total) {
  $("#regex-progress-pass").css("width", Math.floor(passing/total*100) + "%");
  $("#regex-progress-fail").css("width", Math.floor(failing/total*100) + "%");
}

function oneOf(texts) {
  return texts[Math.floor(Math.random() * texts.length)];
}

function updateInputBox(result) {
  var textbox = $("#regex-guess"),
      button = $("#regex-submit"),
      group = $("#regex-input");

  if (result == "failed") {

    textbox.one("input", updateInputBox);
    button.text(oneOf(failedText));
    group.addClass("has-error");

  } else if (result == "passed") {

    textbox.one("input", updateInputBox);
    button.text(oneOf(passedText));
    group.addClass("has-success")

  } else if (result == "finished") {

    textbox.attr("disabled", "disabled");
    button.attr("disabled", "disabled")
          .text(oneOf(finishedText))
          .addClass("btn-success");
    group.addClass("has-success");
  } else {

    button.text("This will work!")
         .removeClass("btn-success");
    group.removeClass("has-success")
         .removeClass("has-error");
  }
}

function handleRegexEnter (e) {
  if (e.which == 13) {
    runRegex();
    return false;
  }
}

function prepRegexStr(regexstr) {
  return "^" + regexstr.replace(/\(/g, "(?:") + "$"
}

function runRegex () {
  var regexstr = $("#regex-guess").val();
  if (regexstr.length == 0)
    return;
  var regex = new RegExp(prepRegexStr(regexstr));
  var results = createElement("table").addClass("table");
  var tests = Math.min(testCases.length-1, curTest);
  var failing = 0,
      result = "failed";

  var i;
  for (i = 0; i <= curTest; i++) {
    if (!testRegex(regex, testCases[i], results)) {
      failing++;
    }
  }
  if (!failing) {
    result = "passed";
    for (i = curTest+1; i < testCases.length; i++) {
      if (!testRegex(regex, testCases[i], results)) {
        failing++;
        break;
      }
    }
    curTest = i;
  }
  if (curTest == testCases.length) {
    result = "finished";
  }

  updateInputBox(result);
  updatePreviousRegexes(regexstr, results);
  updateCurrentTests();
  updateProgressBars(curTest+1-failing, failing, testCases.length);
  $("#regex-guess").focus();
}

function updatePreviousRegexes(regex, results) {
  var container = $("#regex-previous");
  var row = createElement("div").addClass("row")
    .append(createElement("div")
      .addClass("col-md-6").addClass("table-label").addClass("regex-text")
      .text(regex))
    .append(createElement("div").addClass("col-md-6")
      .append(results));

  if (container.css("display") == "none") {
    row.prependTo($("#regex-results"))
    container.slideDown();
  } else {
    row.hide().prependTo($("#regex-results")).slideDown();
  }
}

function testRegex(regex, test, appendTo) {
  var matched = regex.exec(test[0]);

  if (test[1] == matched) {
    appendTo.prepend(createElement("tr")
      .addClass("success")
      .append(createElement("td")
          .text(test[0]))
      .append(createElement("td")
          .text("passed! matched " + test[1])));
    return true;
  } else {
    appendTo.prepend(createElement("tr")
      .addClass("danger")
      .append(createElement("td")
          .text(test[0]))
      .append(createElement("td")
          .text("failed! expected " + getMatchText(test[1]) + 
                ", matched " + getMatchText(matched))));
    return false;
  }
}
