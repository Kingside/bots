(function() {
  var bots, robot;

  bots = require('..');

  robot = new bots.Bot;

  robot.use(bots.cli);

  robot.start();

}).call(this);
