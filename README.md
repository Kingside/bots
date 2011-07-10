hecticbot
=========

An experiment in building a 'bot framework that can be extended using plugins.

## Features

* Simple core
* DSL for defining bot personality
* Multi-interface
  * XMPP
  * Campfire
  * Command line
* Hooks system for extending
  * Startup
  * New event
  * Before processing
  * After processing
  * Shutdown
* Redis for short term memory
* MongoDB for long term memory

## Installing

    git clone https://github.com/hecticjeff/hecticbot
    cd hecticbot
    npm install

## Building a bot

The most basic bot uses the cli for input and outputs to stdout. It
would look something like this.

``` javascript
var bot = require('hecticbot');

var c3po = bot.createBot('c3po 1.0.0');

c3po.use(bot.cli());

c3po.hear(/thanks/, function(message) {
  message.say("Oh you're perfectly welcome, sir.");
});

c3po.start();```
## Documentation

[man hecticbot](http://hecticjeff.github.com/hecticbot)

Copyright (c) 2011 Chris Mytton
