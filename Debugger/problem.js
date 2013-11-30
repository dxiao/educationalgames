// Class Sequence Constructor
function Sequence(string) {
  if (string != null) {
    this.str = string;
  } else {
    this.str = "";
  }
}
// Class Sequence Object Methods
Sequence.prototype = {
  findLetterAfter : function (letter, afterPosition) {
    var i;
    for (i = afterPosition+1; i < this.str.length; i++)
      if (this.str[i] == letter)
        return i;
    return -1;
  },
  addLetter : function (letter) {
    return new Sequence(
  }
  toString: function () {
    return this.str;
  }
}

// Class SubsequenceSearch Constructor
function SubsequenceSearch(sequences, indeces, subsequence) {
  this.sequences = sequences;
  if (indeces == null)
    this.indeces = [0] * sequences.length;
  else
    this.indeces = indeces;

  if (subsequence == null)
    this.subsequence = new Sequence();
  else
    this.subsequence = subsequence;
}
// Class SubsequenceSearch Object Methods
SubsequenceSearch.prototype = {
  tryAddLetter: function (letter) {
    var length = this.sequences.length;
    var newIndeces = [0] * length;
    var i = 0;
    for (; i < length; i++) {
      if ((newIndeces = this.sequences[i].addLetter(letter)) == -1) {
        break;
      }
    }
    if (i == length) {
      var newSubsequence = this.subsequence.addLeter(letter);
      return new SubsequenceSearch(this.sequences, newIndeces, newSubsequence);
    } else {
      return null;
    }
  },
  extendSearch: function() {
    var i = this.indeces[0];
    var length = this.sequences[0].length;
    var extendedSearch;
    var longestSubsequence = this.subsequence;
    var curSubsequence;
    for (; i < this.sequences[0].length; i++) {
      if ((extendedSearch = this.tryAddLetter(this.sequences[0][i])) != null) {
        curSubsequence = extendedSearch.extendSearch();
        if (curSubsequence.length > longestSubsequence.length) {
          longestSubsequence = curSubsequence;
        }
      }
    }
    return longestSubsequence;
  }
}
// Class SubsequenceSearch static methods
SubsequenceSearch.findLongest = function (strings) {
  return new SubsequenceSearch(strings).extendSearch();
}
