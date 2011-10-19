bots
====

Make your own robot that knows how to speak many protocols, and can be
taught more.

## Installing

By installing globally you gain access to the `bots(1)` tool which can
generate bots for you.

    npm -g install bots

## Tutorial

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
in a file called `coolbot.js`.

``` javascript
// Pull in the bots framework.
var bots = require('bots');

// Create your own cool bot and give it a name.
var coolbot = bots.createBot('coolbot 0.0.1');

// Tell this cool bot to use the CLI interface (stdin/stdout).
coolbot.use(bots.cli());

// Add a description and it will appear when the bot hears "help".
coolbot.desc('ping', "Test I'm working with a ping");

// Assign an action to the bot, first argument is the regex to match,
// second is the callback to be invoked when this message is matched.
coolbot.hear(/ping/, function(message) {

  // Respond to the person who sent the message, note that you don't
  // *have* to call `message.say`.
  message.say("PONG");
});

// Start you cool bot listening on the interfaces you have assigned.
coolbot.start();
```

Now try running it:

```
$ node coolbot.js
ping
PONG
```

This example uses the `cli` interface, this can be useful for testing, and
the bot can take commands on stdin, so can be used in a pipe, but for other
services you'll need to `use` different interfaces.

## Contributing

Get the code and run the tests.

    git clone https://github.com/hecticjeff/bots
    cd bots
    npm install
    npm test

## Credits

Parts of the dsl design were inspired by
[defunkt/evilbot](https://github.com/defunkt/evilbot).

Copyright (c) 2011 Chris Mytton
