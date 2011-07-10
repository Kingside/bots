# The main `Robot` class is used for creating robots. You can define
# behaviour through the simple dsl that is provided.
{request} = require './utils'

module.exports = class Robot
  constructor: ->
    @handlers = []
    @descriptions = {}

  get: (path, body, callback) ->
    request('GET', path, body, callback)

  desc: (phrase, functionality) ->
    @descriptions[phrase] = functionality

  hear: (pattern, callback) =>
    @handlers.push [pattern, callback]

  dispatch: (message) =>
    for pair in @handlers
      [ pattern, handler ] = pair
      handler(message) if message.match = message.body.match(pattern)

  use: (interface) ->
    interface.on 'message', @dispatch

  configure: (callback) ->
    callback @hear

  xmppDispatch: (message) ->
    for pair in @handlers
      [ pattern, handler ] = pair
      if match = message.body.match(pattern)
        message.match = match
        message.say = (thing, callback) ->
          message.children[0].children[0] = thing
          message.client.send message
          callback?()
        handler(message)

Cli = require './cli'
cli = new Cli()
testBot = new Robot()
testBot.use cli

testBot.configure (hear) ->
  hear /ping/, (message) -> message.say 'PONG!'
  hear /image me (.+)/, (message) -> message.say "You want #{message.match[1]}"
