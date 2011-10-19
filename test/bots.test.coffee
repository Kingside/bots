bots = require '../src'
robot = bots.createBot 'robot'
{testCase} = require 'nodeunit'

module.exports = testCase
  setUp: (next) ->
    robot.reset next

  'test making robots': (test) ->
    test.expect 12
    test.equal 0, robot.handlers.length
    test.equal 0, Object.keys(robot.descriptions).length

    robot.desc 'testing', 'no-op for testing'
    test.equal 1, Object.keys(robot.descriptions).length

    robot.hear /testing/, ->
    test.equal 1, robot.handlers.length

    robot.desc 'hello', 'a friendly hello'
    test.equal 2, Object.keys(robot.descriptions).length

    robot.hear /hello/, (msg) -> msg.say('hello!')
    test.equal 2, robot.handlers.length

    for handler in robot.handlers
      test.ok Array.isArray(handler)
      test.equal 2, handler.length
      test.ok handler[0].exec

    test.done()

  'test adding interfaces': (test) ->
    robot.use bots.cli()
    test.equal 1, robot.interfaces.length
    test.done()

  'test dispatching simple commands': (test) ->
    test.expect(1)
    robot.interfaces = []
    robot.hear /hello/, (msg) ->
      test.equal 'hello', msg.match[0]
      test.done()

    robot.dispatch body: 'hello there'

  'test dispatching commands with matches': (test) ->
    robot.hear /where is (.+)/, (msg) ->
      test.ok msg.body.match(/where is/)
      test.equal 'wally', msg.match[1]
      test.done()

    robot.dispatch body: 'not this one'
    robot.dispatch body: 'where is wally'

  'test bot start event': (test) ->
    robot.on 'start', ->
      test.done()

    robot.start()
