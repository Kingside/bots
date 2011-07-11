bots = require '..'
testbot = bots.createBot 'testbot'
{testCase} = require 'nodeunit'

module.exports = testCase
  setUp: (next) ->
    testbot.reset next

  'test making robots': (test) ->
    test.equal 0, testbot.handlers.length

    testbot.desc 'testing', 'no-op for testing'
    test.equal 1, Object.keys(testbot.descriptions).length

    testbot.hear /testing/, ->
    test.equal 1, testbot.handlers.length

    testbot.desc 'hello', 'a friendly hello'
    test.equal 2, Object.keys(testbot.descriptions).length

    testbot.hear /hello/, (msg) -> msg.say('hello!')
    test.equal 2, testbot.handlers.length

    for handler in testbot.handlers
      test.ok Array.isArray(handler)
      test.equal 2, handler.length
      test.ok handler[0].exec

    test.done()
