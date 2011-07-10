var bot = require('..');

var c3po = bot.createBot('c3po 1.0.0');

c3po.use(bot.cli());

c3po.desc('thanks');
c3po.hear(/thanks/, function(message) {
  message.say("Oh you're perfectly welcome, sir.");
});

c3po.desc('tweets');
c3po.hear(/tweets/, function(message) {
  this.get('http://api.twitter.com/1/statuses/user_timeline.json?screen_name=c3po', function(body) {
    body.forEach(function(tweet) {
      message.say(tweet.text);
    });
  });
});

c3po.start();
