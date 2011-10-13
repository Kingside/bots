(function() {
  var Bot, EventEmitter, fs, request;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __slice = Array.prototype.slice;
  EventEmitter = require('events').EventEmitter;
  request = require('request');
  fs = require('fs');
  exports.version = JSON.parse(fs.readFileSync(__dirname + "/../package.json")).version;
  exports.createBot = function(name) {
    return new Bot(name);
  };
  exports.Bot = Bot = (function() {
    __extends(Bot, EventEmitter);
    function Bot(name) {
      this.name = name;
      this.dispatch = __bind(this.dispatch, this);
      this.hear = __bind(this.hear, this);
      this.desc = __bind(this.desc, this);
      this.handlers = [];
      this.interfaces = [];
      this.descriptions = {};
    }
    Bot.prototype.setup = function(nickname, callback) {
      if (typeof nickname === 'function') {
        callback = nickname;
      } else {
        this.nickname = nickname;
      }
      return callback(this.desc, this.hear);
    };
    Bot.prototype.desc = function(phrase, functionality) {
      return this.descriptions[phrase] = functionality;
    };
    Bot.prototype.hear = function(pattern, callback) {
      return this.handlers.push([pattern, callback]);
    };
    Bot.prototype.use = function(interface) {
      this.interfaces.push(interface);
      return interface.on('message', this.dispatch);
    };
    Bot.prototype.dispatch = function(message) {
      var handler, pair, pattern, _i, _len, _ref, _results;
      _ref = this.handlers;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pair = _ref[_i];
        if (this.nickname) {
          if (!message.body.match(new RegExp("^" + this.nickname))) {
            continue;
          }
        }
        pattern = pair[0], handler = pair[1];
        _results.push((message.match = message.body.match(pattern)) ? handler.call(this, message) : void 0);
      }
      return _results;
    };
    Bot.prototype.start = function() {
      var interface, _i, _len, _ref;
      _ref = this.interfaces;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        interface = _ref[_i];
        interface.listen();
      }
      this.hear(/help/, this.help);
      return this.emit('start');
    };
    Bot.prototype.stop = function(finished) {
      var closing, interface, _i, _len, _ref, _results;
      console.log("\nStopping " + this.name);
      closing = this.interfaces.length;
      _ref = this.interfaces;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        interface = _ref[_i];
        _results.push(interface.close(function() {
          if (--closing === 0) {
            return finished();
          }
        }));
      }
      return _results;
    };
    Bot.prototype.reset = function(callback) {
      this.handlers = [];
      this.descriptions = [];
      return typeof callback === "function" ? callback() : void 0;
    };
    Bot.prototype.get = function(uri, body, callback) {
      return this.request('GET', uri, body, callback);
    };
    Bot.prototype.post = function(uri, body, callback) {
      return this.request('POST', uri, body, callback);
    };
    Bot.prototype.help = function(message) {
      if (Object.keys(this.descriptions).length === 0) {
        return message.say("I do not have any actions yet.");
      }
      return message.say("I listen for the following…", __bind(function() {
        var functionality, output, phrase, _ref, _results;
        _ref = this.descriptions;
        _results = [];
        for (phrase in _ref) {
          functionality = _ref[phrase];
          if (functionality) {
            output = phrase + ": " + functionality;
          } else {
            output = phrase;
          }
          _results.push(message.say(output));
        }
        return _results;
      }, this));
    };
    Bot.prototype.request = function(method, uri, body, callback) {
      var options;
      options = {
        method: method,
        uri: uri
      };
      options.headers = {
        'User-Agent': this.name
      };
      if (typeof body === 'function' && !callback) {
        callback = body;
        body = null;
      }
      if (typeof body === 'string') {
        options.body = body;
      } else {
        options.json = body;
      }
      return request(options, function(err, response, body) {
        try {
          body = JSON.parse(body);
        } catch (e) {

        }
        return typeof callback === "function" ? callback(body, response) : void 0;
      });
    };
    return Bot;
  })();
  exports.cli = function() {
    var Cli;
    Cli = require('./interfaces/cli');
    return new Cli;
  };
  exports.campfire = function() {
    var Campfire, args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    Campfire = require('./interfaces/campfire');
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return typeof result === "object" ? result : child;
    })(Campfire, args, function() {});
  };
  exports.xmpp = function() {
    var Xmpp, args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    Xmpp = require('./interfaces/xmpp');
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return typeof result === "object" ? result : child;
    })(Xmpp, args, function() {});
  };
  exports.generate = require('./generator');
}).call(this);
