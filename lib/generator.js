(function() {
  var fs;

  fs = require('fs');

  module.exports = function(name, version) {
    if (!name) {
      console.log("Usage: bots NAME");
      process.exit(-1);
    }
    console.log("Generating " + name);
    return fs.mkdir(name, '0755', function(err) {
      if (err) throw err;
      return fs.writeFile("" + name + "/index.js", "var bots = require('bots');\n\nvar " + name + " = bots.createBot('" + name + " 0.0.0');\n\n" + name + ".use(bots.cli());\n\n" + name + ".desc('ping', 'smoke test');\n" + name + ".hear(/ping/, function(msg) {\n  msg.say('pong from ' + this.name);\n});\n\n" + name + ".desc('tell me about THING', 'Searches twitter for THING');\n" + name + ".hear(/tell me about (.+)/, function(msg) {\n  this.get('http://search.twitter.com/search.json?lang=en&q=' + msg.match[1], function(body) {\n    body.results.forEach(function(tweet) {\n      msg.say(tweet.text);\n    });\n  });\n});\n\n" + name + ".on('start', function() {\n  console.log(\"Try typing 'help' or 'ping'.\");\n});\n\n" + name + ".start();\n", function(err) {
        if (err) throw err;
        return fs.writeFile("" + name + "/package.json", "{\n  \"name\": \"" + name + "\",\n  \"version\": \"0.0.0\",\n  \"description\": \"\",\n  \"author\": \"\",\n  \"main\": \"./index\",\n  \"engines\": {\n    \"node\": \"0.4\"\n  },\n  \"dependencies\": {\n    \"bots\": \"" + version + "\"\n  },\n  \"scripts\": {\n    \"start\": \"node index.js\"\n  }\n}\n", function(err) {
          if (err) throw err;
          return fs.writeFile("" + name + "/README.md", "# " + name + "\n\n## Install\n\n    npm install\n\n## Usage\n\n    npm start\n\nWritten with [hecticjeff/bots](https://github.com/hecticjeff/bots) v" + version + "\n", function(err) {
            if (err) throw err;
            return console.log("...done");
          });
        });
      });
    });
  };

}).call(this);
