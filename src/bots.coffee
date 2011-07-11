# The main `Bot` class that all robots are created from, this contains the
# main functions for assembling a bot.
{EventEmitter} = require 'events'
http = require 'http'

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
    @hear /help/, @help
    @interfaces.forEach (i) -> i.listen()
    @emit 'start'

  # Reset the bot's `handlers` and `descriptions`, note this does not stop
  # the registered interfaces from listening.
  reset: (callback) ->
    @handlers = []
    @descriptions = []
    callback?()

  # Helper method for making a `GET` request, proxies to the `request`
  # method.
  get: (path, body, callback) ->
    @request('GET', path, body, callback)

  # Helper method for making a `POST` request, proxies to the `request`
  # method.
  post: (path, body, callback) ->
    @request('POST', path, body, callback)

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
  request: (method, path, body, callback) ->
    if match = path.match(/^(https?):\/\/([^\/]+?)(\/.+)/)
      headers = { Host: match[2], 'Content-Type': 'application/json', 'User-Agent': @name }
      port = if match[1] == 'https' then 443 else 80
      client = http.createClient(port, match[2], port == 443)
      path = match[3]

      if typeof(body) is 'function' and not callback
        callback = body
        body = null

      if method is 'POST' and body
        body = JSON.stringify body if typeof body isnt 'string'
        headers['Content-Length'] = body.length

      req = client.request(method, path, headers)

      req.on 'response', (response) ->
        if response.statusCode is 200
          data = ''
          response.setEncoding('utf8')
          response.on 'data', (chunk) ->
            data += chunk
          response.on 'end', ->
            if callback
              try
                body = JSON.parse(data)
              catch e
                body = data
              callback body
        else if response.statusCode is 302
          request(method, path, body, callback)
        else
          console.log "#{response.statusCode}: #{path}"
          response.setEncoding('utf8')
          response.on 'data', (chunk) ->
            console.log chunk.toString()
          process.exit(1)
    req.write(body) if method is 'POST' and body
    req.end()

# Command line interface.
Cli = require './cli'
exports.cli = ->
  new Cli

# Campfire interface.
Campfire = require './campfire'
exports.campfire = (args...) ->
  new Campfire args...

# XMPP interface.
Xmpp = require './xmpp'
exports.xmpp = (args...) ->
  new Xmpp args...
