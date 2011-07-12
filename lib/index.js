var Bot, Campfire, Cli, EventEmitter, Xmpp, http;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
}, __slice = Array.prototype.slice;
EventEmitter = require('events').EventEmitter;
http = require('http');
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
      pattern = pair[0], handler = pair[1];
      _results.push((message.match = message.body.match(pattern)) ? handler.call(this, message) : void 0);
    }
    return _results;
  };
  Bot.prototype.start = function() {
    var i, _i, _len, _ref;
    _ref = this.interfaces;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      i.listen();
    }
    this.hear(/help/, this.help);
    return this.emit('start');
  };
  Bot.prototype.stop = function(finished) {
    var closing, i, _i, _len, _ref, _results;
    console.log("\nStopping " + this.name);
    closing = this.interfaces.length;
    _ref = this.interfaces;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      _results.push(i.close(function() {
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
  Bot.prototype.get = function(path, body, callback) {
    return this.request('GET', path, body, callback);
  };
  Bot.prototype.post = function(path, body, callback) {
    return this.request('POST', path, body, callback);
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
  Bot.prototype.request = function(method, path, body, callback) {
    var client, headers, match, port, req;
    if (match = path.match(/^(https?):\/\/([^\/]+?)(\/.+)/)) {
      headers = {
        Host: match[2],
        'Content-Type': 'application/json',
        'User-Agent': this.name
      };
      port = match[1] === 'https' ? 443 : 80;
      client = http.createClient(port, match[2], port === 443);
      path = match[3];
      if (typeof body === 'function' && !callback) {
        callback = body;
        body = null;
      }
      if (method === 'POST' && body) {
        if (typeof body !== 'string') {
          body = JSON.stringify(body);
        }
        headers['Content-Length'] = body.length;
      }
      req = client.request(method, path, headers);
      req.on('response', function(response) {
        var data;
        if (response.statusCode === 200) {
          data = '';
          response.setEncoding('utf8');
          response.on('data', function(chunk) {
            return data += chunk;
          });
          return response.on('end', function() {
            if (callback) {
              try {
                body = JSON.parse(data);
              } catch (e) {
                body = data;
              }
              return callback(body);
            }
          });
        } else if (response.statusCode === 302) {
          return request(method, path, body, callback);
        } else {
          console.log("" + response.statusCode + ": " + path);
          response.setEncoding('utf8');
          response.on('data', function(chunk) {
            return console.log(chunk.toString());
          });
          return process.exit(1);
        }
      });
    }
    if (method === 'POST' && body) {
      req.write(body);
    }
    return req.end();
  };
  return Bot;
})();
Cli = require('./cli');
exports.cli = function() {
  return new Cli;
};
Campfire = require('./campfire');
exports.campfire = function() {
  var args;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  return (function(func, args, ctor) {
    ctor.prototype = func.prototype;
    var child = new ctor, result = func.apply(child, args);
    return typeof result === "object" ? result : child;
  })(Campfire, args, function() {});
};
Xmpp = require('./xmpp');
exports.xmpp = function() {
  var args;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  return (function(func, args, ctor) {
    ctor.prototype = func.prototype;
    var child = new ctor, result = func.apply(child, args);
    return typeof result === "object" ? result : child;
  })(Xmpp, args, function() {});
};