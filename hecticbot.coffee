# Hecticbot, the little bot that could.
#
# A little bot to keep you company on those dark lonely winter nights.
http = require 'http'
{exec} = require 'child_process'
ranger = require 'ranger'

ua = "Hecticbot 0.0.1"

roomId = parseInt process.env.CAMPFIRE_ROOM
userId = parseInt process.env.CAMPFIRE_USER
account = process.env.CAMPFIRE_ACCOUNT
apiKey = process.env.CAMPFIRE_API_KEY
jid = process.env.HECTICBOT_JID
jidPassword = process.env.HECTICBOT_PASSWORD

# Hecticbot's brain
campfire = ranger.createClient(account, apiKey)
chat = require './xmpp'

client = chat.createClient jid, jidPassword

client.on 'message', (stanza) ->
  stanza.attrs.to = stanza.attrs.from
  delete stanza.attrs.from
  xmppDispatch(stanza) if stanza.body

request = (method, path, body, callback) ->
  if match = path.match(/^(https?):\/\/([^\/]+?)(\/.+)/)
    headers = { Host: match[2], 'Content-Type': 'application/json', 'User-Agent': ua }
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

handlers = []

dispatch = (message) ->
  for pair in handlers
    [ pattern, handler ] = pair
    if message.userId isnt userId and match = message.body.match(pattern)
      message.match = match
      message.say = (thing, callback) -> say(message.room, thing, callback)
      handler(message)

xmppDispatch = (message) ->
  for pair in handlers
    [ pattern, handler ] = pair
    if match = message.body.match(pattern)
      message.match = match
      message.say = (thing, callback) ->
        message.children[0].children[0] = thing
        message.client.send message
        callback?()

      handler(message)

listen = (message) ->
  if message.type is 'TextMessage'
    dispatch(message)
    log message

# Hecticbot's heart
campfire.room roomId, (room) ->
  room.join()
  console.log "Joined #{room.name}"
  room.listen (message) ->
    message.room = room
    listen(message)

  process.on 'SIGINT', ->
    room.leave ->
      console.log "\nI'll be back"
      process.exit()

http.createServer (req, res) ->
  res.writeHead 200, 'Content-Type': 'text/plain'
  res.end "Bow down to hecticbot"
.listen process.env.PORT || 3000

# Hecticbot's actions

get = (path, body, callback) ->
  request('GET', path, body, callback)

say = (room, message, callback) ->
  room.speak(message, callback)

hear = (pattern, callback) ->
  handlers.push [pattern, callback]

descriptions = {}
desc = (phrase, functionality) ->
  descriptions[phrase] = functionality

log = (message) ->
  console.log "#{message.room.name} >> #{message.body}"

# Hecticbot's personality (stolen from evilbot)

hear /feeling/, (message) ->
  message.say "i feel... alive"

hear /about/, (message) ->
  message.say "I am learning to love."

hear /ping/, (message) ->
  message.say "PONG"

hear /reload/, (message) ->
  message.say "Reloading…", ->
    exec "cd #{__dirname} && git fetch origin && git reset --hard origin/master", (err, stdout)->
      throw err if err
      console.log stdout
      process.exit(1)

hear /help/, (message) ->
  message.say "I listen for the following…", ->
    for phrase, functionality of descriptions
      if functionality
        output =  phrase + ": " + functionality
      else
        output = phrase
      message.say output

desc 'adventure me'
hear /adventure me/, (message) ->
  txts = [
    "You are in a maze of twisty passages, all alike.",
    "It is pitch black. You are likely to be eaten by a grue.",
    "XYZZY",
    "You eat the sandwich.",
    "In this feat of unaccustomed daring, you manage to land on your feet without killing yourself.",
    "Suicide is not the answer.",
    "This space intentionally left blank.",
    "I assume you wish to stab yourself with your pinky then?",
    "Talking to yourself is a sign of impending mental collapse.",
    "Clearly you are a suicidal maniac. We don't allow psychotics in the cave, since they may harm other adventurers.",
    "Auto-cannibalism is not the answer.",
    "Look at self: \"You would need prehensile eyeballs to do that.\"",
    "The lamp is somewhat dimmer. The lamp is definitely dimmer. The lamp is nearly out. I hope you have more light than the lamp.",
    "What a (ahem!) strange idea!",
    "Want some Rye? Course ya do!"
  ]
  txt = txts[ Math.floor(Math.random()*txts.length) ]

  message.say txt

desc 'commit'
hear /commit/, (message) ->
  url = "http://whatthecommit.com/index.txt"

  get url, (body) ->
    message.say body

desc 'hecticjeff'
hear /hecticjeff/i, (message) ->
  message.say "He da man"

desc 'fortune'
hear /fortune/, (message) ->
  url = "http://www.fortunefortoday.com/getfortuneonly.php"

  get url, (body) ->
    message.say body

desc 'chuck'
hear /chuck/i, (message) ->
  url = "http://api.icndb.com/jokes/random"

  get url, (body) ->
    message.say body['value']['joke']

desc 'weather in PLACE'
hear /weather in (.+)/i, (message) ->
  place = message.match[1]
  url   = "http://www.google.com/ig/api?weather=#{escape place}"

  get url, (body) ->
    try
      if match = body.match(/<current_conditions>(.+?)<\/current_conditions>/)
        icon = match[1].match(/<icon data="(.+?)"/)
        degrees = match[1].match(/<temp_c data="(.+?)"/)
        message.say "#{degrees[1]}° — http://www.google.com#{icon[1]}"
    catch e
      console.log "Weather error: " + e

desc 'wiki me PHRASE', 'returns a wikipedia page for PHRASE'
hear /wiki me (.*)/i, (message) ->
  term = escape(message.match[1])
  url  = "http://en.wikipedia.org/w/api.php?action=opensearch&search=#{term}&format=json"

  get url, (body) ->
    try
      if body[1][0]
        message.say "http://en.wikipedia.org/wiki/#{escape body[1][0]}"
      else
        message.say "nothin'"
    catch e
      console.log "Wiki error: " + e

desc 'image me PHRASE'
hear /image me (.*)/i, (message) ->
  phrase = escape(message.match[1])
  url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&safe=active&q=#{phrase}"

  get url, (body) ->
    try
      images = body.responseData.results
      image  = images[ Math.floor(Math.random()*images.length) ]
      message.say image.unescapedUrl
    catch e
      console.log "Image error: " + e

hear /(the rules|the laws)/i, (message) ->
  message.say "1. A robot may not injure a human being or, through inaction, allow a human being to come to harm.", ->
    message.say "2. A robot must obey any orders given to it by human beings, except where such orders would conflict with the First Law.", ->
      message.say "3. A robot must protect its own existence as long as such protection does not conflict with the First or Second Law."

hear /(respond|answer me|bij)/i, (message) ->
  message.say "Chill, Winston."
