bots
====

Make your own robot that knows how to speak many protocols, and can be
taught more.

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

So, you want to build your own 'bot. You've heard that all the cool hip
startups have their own office 'bot, you know, the one that monitors the
CI system, can deploy the site, play music over the office speakers AND
knows who's in the office based on their smartphones wi-fi presence. Well
follow along and you can build your very own robot servant to perform your
nefarious deeds.

First you need to get the parts to build the bot. You'll need to get setup
with [node(1)](http://nodejs.org/) and it's de-facto package manager,
[npm(1)](http://npmjs.org/). Then create a project and get the parts.

    mkdir coolbot && cd coolbot
    npm install bots

Now you'll need to give the robot some personality, try putting the following
in a file called `coolbot.js` and running it with `node coolbot.js`, then try
typing **ping**, coolbot should respond with pong.

``` javascript
var bots = require('bots');
var coolbot = bots.createBot('coolbot 0.0.1');
coolbot.use(bots.cli());
coolbot.desc('ping', 'Test I'm working with a ping');
coolbot.hear(/ping/, function(message) {
  message.say("PONG");
});
coolbot.start();
```

This example uses the `cli` interface, this can be useful for testing, and
the bot can take commands on stdin, so can be used in a pipe, but for other
services you'll need to `use` different interfaces.

## Documentation

[man hecticbot](http://hecticjeff.github.com/hecticbot)

Copyright (c) 2011 Chris Mytton
