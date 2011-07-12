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

  close: (done) ->
    @client.end()
    done()

  updatePresence: =>
    puts "XMPP Connected"
    @client.send new xmpp.Element('presence', {}).c('show').t('chat').up()
      .c('status').t('Happily echoing your <message /> stanzas')

  handle: (stanza) =>
    if stanza.is('message') and stanza.attrs.type isnt 'error'
      message =
        say: (thing, callback) =>
          @client.send @createReply(stanza.attrs.from, thing)
          callback?()

      for child in stanza.children
        message.body = child.children.join('\n') if child.name is 'body'

      @emit 'message', message if message.body

  createReply: (to, text) ->
    new xmpp.Element('message', to: to, type: 'chat')
      .c('body').t(text)

