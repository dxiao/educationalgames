var express = require("express"),
    http = require("http"),
    app = express();

app.use(express.logger());
app.use(express.bodyParser());
app.use("/", express.static(__dirname));

var buffer = []

app.post("/monitoring", function(req, res) {
  buffer.push([req.ip, new Date().toLocaleTimeString(), 
    req.body.puzzle, req.body.ordering, req.body.finalState])
  res.send(200)
})

app.get("/monitoring", function(req, res) {
  res.json(buffer)
  buffer = []
})

app.listen(8888);
