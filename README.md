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

## Documentation

[man hecticbot](http://hecticjeff.github.com/hecticbot)

Copyright (c) 2011 Chris Mytton
