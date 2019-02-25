var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
  let users = [
    {lastname: "Woods", firstname: "Tiger"},
    {lastname: "Mc Ilroy", firstname: "Rory"}
  ]
  res.json(users)
})

module.exports = router;
