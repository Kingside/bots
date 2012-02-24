{EventEmitter} = require 'events'

exports.name = 'cli'

# Attach the cli interface to the bot.
exports.attach = ->
  @cli = new Cli

exports.init = ->
  # When the bot emits a start event we need to begin listening.
  @on 'start', @cli.listen
  @on 'message', @cli.handle

class Cli extends EventEmitter
  listen: =>
    if command = process.argv.slice(2).join(' ')
      @handle command
    else
      process.stdin.resume()
      process.stdin.setEncoding 'utf8'
      process.stdin.on 'data', @handle

  handle: (chunk) =>
    message =
      body: chunk.toString()
      say: (thing, callback) ->
        console.log thing
        callback?()

    @emit 'message', message
