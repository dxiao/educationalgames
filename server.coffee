express = require "express"
http = require "http"
debugApp = require "./debugger/server.coffee"

app = express()
app.use express.logger()
app.use express.bodyParser()

app.use "/racer", express.static __dirname + "/Racer/"
app.use "/regex", express.static __dirname + "/Regex/"
app.use "/common/", express.static __dirname + "/Common/"
debugApp.useExpressServer app

buffer = []

app.post "/Racer/monitoring", (req, res) ->
  buffer.push [req.ip, new Date().toLocaleTimeString(),
    req.body.puzzle, req.body.ordering, req.body.finalState]
  res.send 200

app.get "/Racer/monitoring", (req, res) ->
  res.json buffer
  buffer = []

app.listen 8888
