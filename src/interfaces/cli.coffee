{EventEmitter} = require 'events'

module.exports = class Cli extends EventEmitter
  listen: ->
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
