var Campfire, EventEmitter, ranger;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
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
  function Campfire(options) {
    this.options = options != null ? options : {};
    this.handle = __bind(this.handle, this);
    this.joinRoom = __bind(this.joinRoom, this);
    this.client = ranger.createClient(this.options.account, this.options.apiKey);
  }
  Campfire.prototype.listen = function() {
    return this.client.room(this.options.roomId, this.joinRoom);
  };
  Campfire.prototype.joinRoom = function(room) {
    this.room = room;
    this.room.join();
    console.log("Joined " + room.name);
    return this.room.listen(this.handle);
  };
  Campfire.prototype.close = function(done) {
    return this.room.leave(done);
  };
  Campfire.prototype.log = function(message) {
    return console.log("" + this.room.name + " >> " + message.body);
  };
  Campfire.prototype.handle = function(message) {
    if (message.type === 'TextMessage' && message.userId !== this.options.userId) {
      this.log(message);
      message.say = __bind(function(text, callback) {
        return this.room.speak(text, callback);
      }, this);
      return this.emit('message', message);
    }
  };
  return Campfire;
})();