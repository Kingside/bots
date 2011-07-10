# The `Hecticbot` class, this is the main external API for the bot.
# It provides and abstraction on top of various interfaces to perform various
# 'bot actions.
http = require 'http'
{exec} = require 'child_process'

# Configuration
ua = "Hecticbot 0.0.1"

jid = process.env.HECTICBOT_JID
jidPassword = process.env.HECTICBOT_PASSWORD

# Interfaces
chat = require './xmpp'
campfire = require './campfire'

client = chat.createClient jid, jidPassword

client.on 'message', (stanza) ->
  stanza.attrs.to = stanza.attrs.from
  delete stanza.attrs.from
  xmppDispatch(stanza) if stanza.body

# Hecticbot's heart

http.createServer (req, res) ->
  res.writeHead 200, 'Content-Type': 'text/plain'
  res.end "Bow down to hecticbot"
.listen process.env.PORT || 3000

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
