{EventEmitter} = require 'events'
ranger = require 'ranger'

module.exports = class Campfire extends EventEmitter
  constructor: (@options = {}) ->
    @client = ranger.createClient(@options.account, @options.apiKey)

  listen: ->
    @client.room @options.roomId, @joinRoom

  joinRoom: (room) =>
    @room = room
    @room.join()
    console.log "Joined #{room.name}"
    @room.listen @handle

    process.on 'SIGINT', ->
      @room.leave

  log: (message) ->
    console.log "#{@room.name} >> #{message.body}"

  handle: (message) =>
    if message.type is 'TextMessage' and message.userId isnt @options.userId
      @log message
      message.say = (text, callback) => @room.speak text, callback
      @emit 'message', message
