{EventEmitter} = require 'events'
{puts}         = require 'util'
xmpp           = require 'node-xmpp'

module.exports = class XMPP extends EventEmitter
  constructor: (@jid, @password) ->

  listen: ->
    puts "XMPP connecting as #{@jid}"
    @client = new xmpp.Client
      jid: @jid
      password: @password

    @client.on 'online', @updatePresence
    @client.on 'stanza', @handle
    @client.on 'error', (err) -> console.warn(err)

  updatePresence: =>
    puts "XMPP Connected"
    @client.send new xmpp.Element('presence', {}).c('show').t('chat').up()
      .c('status').t('Happily echoing your <message /> stanzas')

  handle: (stanza) =>
    # Send the response back to where it came from
    stanza.attrs.to = stanza.attrs.from
    delete stanza.attrs.from

    if stanza.is('message') and stanza.attrs.type isnt 'error'
      message =
        body: stanza.children[0].children[0]
        say: (thing, callback) =>
          stanza.children[0].children[0] = thing
          @client.send stanza
          callback?()
      @emit 'message', message if message.body
