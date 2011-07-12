var Campfire, EventEmitter, ranger;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
EventEmitter = require('events').EventEmitter;
ranger = require('ranger');
module.exports = Campfire = (function() {
  __extends(Campfire, EventEmitter);
  function Campfire(account, apiKey) {
    this.client = ranger.createClient(account, apiKey);
    this.joinRoom();
  }
  Campfire.prototype.joinRoom = function() {
    return this.client.room(roomId, function(room) {
      this.room = room;
      this.room.join();
      console.log("Joined " + room.name);
      this.room.listen(function(message) {
        message.room = this.room;
        return this.handle(message);
      });
      return process.on('SIGINT', function() {
        return this.room.leave(function() {
          console.log("\nI'll be back");
          return process.exit();
        });
      });
    });
  };
  Campfire.prototype.log = function(message) {
    return console.log("" + message.room.name + " >> " + message.body);
  };
  Campfire.prototype.say = function(message, callback) {
    return this.room.speak(message, callback);
  };
  Campfire.prototype.handle = function(message) {
    if (message.type === 'TextMessage' && message.userId !== userId) {
      message.say = function(thing, callback) {
        return this.say(message.room, thing, callback);
      };
      this.log(message);
      return this.emit('message', message);
    }
  };
  return Campfire;
})();