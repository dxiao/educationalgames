var express = require("express"),
    http = require("http"),
    app = express();

app.use(express.logger());
app.use(express.bodyParser());
app.use("/racer", express.static(__dirname + "/Racer/"));
app.use("/regex", express.static(__dirname + "/Regex/"));
app.use("/common/", express.static(__dirname + "/Common/"));

var buffer = []

app.post("/Racer/monitoring", function(req, res) {
  buffer.push([req.ip, new Date().toLocaleTimeString(), 
    req.body.puzzle, req.body.ordering, req.body.finalState])
  res.send(200)
})

app.get("/Racer/monitoring", function(req, res) {
  res.json(buffer)
  buffer = []
})

app.listen(8888);
