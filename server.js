var express = require("express");
var app = express();
app.listen(3000);

var bodyParser = require("body-parser");
app.use(bodyParser.urlencoded({extended:false}));

app.get("/", function(req, res) {
    res.send("Hello");
});

app.post("/orders", function(req, res) {
    var stringFromServer = JSON.stringify(req.body);
    console.log(stringFromServer);
});
