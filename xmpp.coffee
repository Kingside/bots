{EventEmitter} = require 'events'
xmpp = require 'node-xmpp'
{puts} = require 'util'

class XMPP extends EventEmitter
  constructor: (jid, password) ->
    puts "XMPP connecting as #{jid}"
    @client = new xmpp.Client
      jid: jid
      password: password
    @client.on 'online', @updatePresence
    @client.on 'stanza', @processStanza
    @client.on 'error', (err) -> console.warn(err)

  updatePresence: =>
    puts "XMPP Connected"
    @client.send new xmpp.Element('presence', {}).c('show').t('chat').up()
      .c('status').t('Happily echoing your <message /> stanzas')

  processStanza: (stanza) =>
    if stanza.is('message') and stanza.attrs.type isnt 'error'
      stanza.body = stanza.children[0].children[0]
      stanza.client = @client
      @emit 'message', stanza
      # stanza.attrs.to = stanza.attrs.from
      # delete stanza.attrs.from
      # @client.send stanza if body

exports.createClient = (u, p) -> new XMPP(u, p)
