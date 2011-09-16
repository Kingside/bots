# The main `Bot` class that all robots are created from, this contains the
# main functions for assembling a bot.
{EventEmitter} = require 'events'
request = require 'request'
http = require 'http'
fs = require 'fs'

# Get the current version from `package.json`.
exports.version = JSON.parse(fs.readFileSync(__dirname + "/../package.json")).version

# Factory method for creating a new `Bot` instance. Accepts a name
# argument, which is the name given to the bot.
#
#     var bots = require('bots');
#
#     var coolbot = bots.createBot('coolbot 1.0.0');
#
exports.createBot = (name) ->
  new Bot name

# The `Bot` class, inherits from `EventEmitter` so it can notify plugins of
# certain lifecycle events.
exports.Bot = class Bot extends EventEmitter

  # Creates a new `Bot` with the given name. Sets up the bot ready to be
  # configured.
  constructor: (@name) ->
    @handlers = []
    @interfaces = []
    @descriptions = {}

  setup: (@nickname, callback) ->
    callback @desc, @hear

  # Adds a description of a piece of the robots functionality, this is used
  # for the robots builtin `help` phrase.
  #
  # * **phrase** - The String representing the phase the bot recognises.
  # * **functionality** - The String describing the phrase (optional).
  #
  # #### Example
  #
  #     bot.desc('image me THING', 'Get a random image of THING');
  #
  desc: (phrase, functionality) =>
    @descriptions[phrase] = functionality

  # Add a `pattern` to the robots repotoire. This is matched against incoming
  # messages and if they match then the message is passed to `callback`.
  #
  # * **pattern** - The RegEx to match against the message body.
  # * **callback** - The Function to be invoked when the pattern is matched.
  #
  # #### Example
  #
  #     bot.hear(/ping/, function(message) {
  #       message.say('PONG');
  #     });
  #
  hear: (pattern, callback) =>
    @handlers.push [pattern, callback]

  # Add an interface to the robot. This is allows the 'bot to communicate
  # with the outside world. See the `Cli` and `XMPP` interfaces for examples,
  # the interface should inherit from EventEmitter, and emit a `message`
  # event when there is a new message on the interface.
  #
  #     var bots = require('bots');
  #     var coolbot = bots.createBot('coolbot 1.0.0');
  #     coolbot.use(bots.cli());
  #
  use: (interface) ->
    @interfaces.push interface
    interface.on 'message', @dispatch

  # Dispatches an incoming message to any handlers that match the message
  # body. This can be used to fake message to the bot, useful for testing
  # the bot. Takes a `message` object with `body` and `say` properties.
  #
  #     coolbot.dispatch({
  #       message: 'ping',
  #       say: function(text, callback) {
  #         console.log(text);
  #         callback();
  #       }
  #     });
  #
  dispatch: (message) =>
    for pair in @handlers
      continue unless message.body.match(new RegExp("^#{@nickname}"))
      [ pattern, handler ] = pair
      handler.call(@, message) if message.match = message.body.match(pattern)

  # Start the bot up, calls listen on the registered interfaces. This registers
  # the **help** phrase that the bot will always repond to. Emits a `start`
  # event when setup is complete.
  #
  #     coolbot.on('start', function() {
  #       console.log("coolbot started");
  #     });
  #     coolbot.start();
  #
  start: ->
    interface.listen() for interface in @interfaces
    @hear /help/, @help
    @emit 'start'

  stop: (finished) ->
    console.log "\nStopping #{@name}"
    closing = @interfaces.length
    for interface in @interfaces
      interface.close ->
        finished() if --closing is 0

  # Reset the bot's `handlers` and `descriptions`, note this does not stop
  # the registered interfaces from listening.
  reset: (callback) ->
    @handlers = []
    @descriptions = []
    callback?()

  # Helper method for making a `GET` request, proxies to the `request`
  # method.
  get: (uri, body, callback) ->
    @request('GET', uri, body, callback)

  # Helper method for making a `POST` request, proxies to the `request`
  # method.
  post: (uri, body, callback) ->
    @request('POST', uri, body, callback)

  # Handler for the default help action, gathers all of the registered
  # descriptions and sends a message describing each action.
  help: (message) ->
    if Object.keys(@descriptions).length is 0
      return message.say "I do not have any actions yet."
    message.say "I listen for the following…", =>
      for phrase, functionality of @descriptions
        if functionality
          output =  phrase + ": " + functionality
        else
          output = phrase
        message.say output

  # Helper to make http requests, tries to automatically handle JSON input and
  # output.
  request: (method, uri, body, callback) ->
    options = { method: method, uri: uri }

    options.headers = { 'User-Agent': @name }

    if typeof(body) is 'function' and not callback
      callback = body
      body = null

    if typeof body is 'string'
      options.body = body
    else
      options.json = body

    request options, (err, response, body) ->
      try
        body = JSON.parse body
      catch e
        # Ignore and pass through the raw body.

      callback? body, response

# Command line interface.
Cli = require './interfaces/cli'
exports.cli = ->
  new Cli

# Campfire interface.
Campfire = require './interfaces/campfire'
exports.campfire = (args...) ->
  new Campfire args...

# XMPP interface.
Xmpp = require './interfaces/xmpp'
exports.xmpp = (args...) ->
  new Xmpp args...

exports.generate = require './generator'
