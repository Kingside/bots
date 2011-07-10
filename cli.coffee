{EventEmitter} = require 'events'

module.exports = class Cli extends EventEmitter
  listen: ->
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
