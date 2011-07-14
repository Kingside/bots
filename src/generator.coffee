fs = require 'fs'

module.exports = (name, version) ->
  unless name
    console.log "Usage: bots NAME"
    process.exit -1

  console.log "Generating #{name}"
  fs.mkdir name, '0755', (err) ->
    throw err if err
    fs.writeFile "#{name}/index.js", """
var bots = require('bots');

var #{name} = bots.createBot('#{name} 0.0.0');

#{name}.use(bots.cli());

#{name}.desc('ping', 'smoke test');
#{name}.hear(/ping/, function(msg) {
  msg.say('pong from ' + this.name);
});

#{name}.desc('tell me about THING', 'Searches twitter for THING');
#{name}.hear(/tell me about (.+)/, function(msg) {
  this.get('http://search.twitter.com/search.json?lang=en&q=' + msg.match[1], function(body) {
    body.results.forEach(function(tweet) {
      msg.say(tweet.text);
    });
  });
});

#{name}.on('start', function() {
  console.log("Try typing 'help' or 'ping'.");
});

#{name}.start();

""", (err) ->
      throw err if err
      fs.writeFile "#{name}/package.json", """
{
  "name": "#{name}",
  "version": "0.0.0",
  "description": "",
  "author": "",
  "main": "./index",
  "engines": {
    "node": "0.4"
  },
  "dependencies": {
    "bots": "#{version}"
  },
  "scripts": {
    "start": "node index.js"
  }
}

""", (err) ->
        throw err if err
        fs.writeFile "#{name}/README.md", """
# #{name}

## Install

    npm install

## Usage

    npm start

Written with [hecticjeff/bots](https://github.com/hecticjeff/bots) v#{version}

  """, (err) ->
          throw err if err
          console.log "...done"
