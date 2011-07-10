ranger = require 'ranger'
Interface = require './interface'

roomId = parseInt process.env.CAMPFIRE_ROOM
userId = parseInt process.env.CAMPFIRE_USER
account = process.env.CAMPFIRE_ACCOUNT
apiKey = process.env.CAMPFIRE_API_KEY

module.exports = class Campfire extends Interface
  constructor: (account, apiKey) ->
    @client = ranger.createClient(account, apiKey)
    @joinRoom()

  joinRoom: ->
    @client.room roomId, (@room) ->
      @room.join()
      console.log "Joined #{room.name}"
      @room.listen (message) ->
        message.room = @room
        @handle(message)

      process.on 'SIGINT', ->
        @room.leave ->
          console.log "\nI'll be back"
          process.exit()

  log: (message) ->
    console.log "#{message.room.name} >> #{message.body}"

  say: (message, callback) ->
    @room.speak message, callback

  handle: (message) ->
    if message.type is 'TextMessage' and message.userId isnt userId
      message.say = (thing, callback) -> @say(message.room, thing, callback)
      @log message
      @emit 'message', message
