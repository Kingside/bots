(function() {
  var Cli, EventEmitter;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  EventEmitter = require('events').EventEmitter;
  module.exports = Cli = (function() {
    __extends(Cli, EventEmitter);
    function Cli() {
      this.handle = __bind(this.handle, this);
      Cli.__super__.constructor.apply(this, arguments);
    }
    Cli.prototype.listen = function() {
      var command;
      if (command = process.argv.slice(2).join(' ')) {
        return this.handle(command);
      } else {
        process.stdin.resume();
        process.stdin.setEncoding('utf8');
        return process.stdin.on('data', this.handle);
      }
    };
    Cli.prototype.handle = function(chunk) {
      var message;
      message = {
        body: chunk.toString(),
        say: function(thing, callback) {
          console.log(thing);
          return typeof callback === "function" ? callback() : void 0;
        }
      };
      return this.emit('message', message);
    };
    return Cli;
  })();
}).call(this);
