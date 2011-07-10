# The main `Robot` class is used for creating robots. You can define
# behaviour through the simple dsl that is provided.
{EventEmitter} = require 'events'
http = require 'http'

exports.createBot = (name) ->
  new Bot name

exports.Bot = class Bot extends EventEmitter
  constructor: (@name) ->
    @handlers = []
    @interfaces = []
    @descriptions = {}

  get: (path, body, callback) ->
    @request('GET', path, body, callback)

  post: (path, body, callback) ->
    @request('POST', path, body, callback)

  desc: (phrase, functionality) =>
    @descriptions[phrase] = functionality

  hear: (pattern, callback) =>
    @handlers.push [pattern, callback]

  dispatch: (message) =>
    for pair in @handlers
      [ pattern, handler ] = pair
      handler.call(@, message) if message.match = message.body.match(pattern)

  use: (interface) ->
    @interfaces.push interface
    interface.on 'message', @dispatch

  help: (message) ->
    message.say "I listen for the following…", =>
      for phrase, functionality of @descriptions
        if functionality
          output =  phrase + ": " + functionality
        else
          output = phrase
        message.say output

  start: ->
    @hear /help/, @help
    @interfaces.forEach (i) -> i.listen()

  configure: (callback) ->
    callback @hear

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


# Interfaces
Cli = require './cli'
exports.cli = ->
  new Cli

Campfire = require './campfire'
exports.campfire = (args...) ->
  new Campfire args...

Xmpp = require './xmpp'
exports.xmpp = (args...) ->
  new Xmpp args...
