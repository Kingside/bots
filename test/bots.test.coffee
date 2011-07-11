bots = require '..'

module.exports =
  'test adding a handler': (test) ->
    bot = bots.createBot 'testbot'
    test.equal 0, bot.handlers.length
    bot.hear /testing/, ->
    bot.hear /hello?/, ->
    test.equal 2, bot.handlers.length
    test.done()
