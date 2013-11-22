var express = require("express"),
    http = require("http"),
    fs = require("fs"),
    app = express();

app.use(express.logger());
app.use("/common/", express.static(__dirname + "/../Common/"));
app.use("/debugger", express.static(__dirname));

var fileTemplate = fs.readFileSync(__dirname + "/problem.js", {encoding: "utf8"}, 
    function (err, data) {
      if (err) throw err;
      console.log(data);
    } ).split("\n");

app.get("/debugger/getsource", function(req, res) {
  var line = parseInt(req.query.line);
  if (line == null) {
    res.send(400, "Line argument not found");
  } else {
    res.send(200, fileTemplate.slice(line, line+7));
  }
});

app.listen(8880);
