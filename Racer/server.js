var express = require("express"),
    http = require("http"),
    app = express();

app.configure(function () {
  app.use("/", express.static(__dirname));
});
app.listen(8888);
