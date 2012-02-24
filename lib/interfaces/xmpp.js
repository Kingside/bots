(function() {
  var EventEmitter, XMPP, puts, xmpp,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  EventEmitter = require('events').EventEmitter;

  puts = require('util').puts;

  xmpp = require('node-xmpp');

  module.exports = XMPP = (function(_super) {

    __extends(XMPP, _super);

    function XMPP(jid, password) {
      this.jid = jid;
      this.password = password;
      this.handle = __bind(this.handle, this);
      this.updatePresence = __bind(this.updatePresence, this);
    }

    XMPP.prototype.listen = function() {
      puts("XMPP connecting as " + this.jid);
      this.client = new xmpp.Client({
        jid: this.jid,
        password: this.password
      });
      this.client.on('online', this.updatePresence);
      this.client.on('stanza', this.handle);
      return this.client.on('error', function(err) {
        return console.warn(err);
      });
    };

    XMPP.prototype.close = function(done) {
      this.client.end();
      return done();
    };

    XMPP.prototype.updatePresence = function() {
      puts("XMPP Connected");
      return this.client.send(new xmpp.Element('presence', {}).c('show').t('chat').up().c('status').t('Happily echoing your <message /> stanzas'));
    };

    XMPP.prototype.handle = function(stanza) {
      var child, message, _i, _len, _ref,
        _this = this;
      if (stanza.is('message') && stanza.attrs.type !== 'error') {
        message = {
          say: function(thing, callback) {
            _this.client.send(_this.createReply(stanza.attrs.from, thing));
            return typeof callback === "function" ? callback() : void 0;
          }
        };
        _ref = stanza.children;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child = _ref[_i];
          if (child.name === 'body') message.body = child.children.join('\n');
        }
        if (message.body) return this.emit('message', message);
      }
    };

    XMPP.prototype.createReply = function(to, text) {
      return new xmpp.Element('message', {
        to: to,
        type: 'chat'
      }).c('body').t(text);
    };

    return XMPP;

  })(EventEmitter);

}).call(this);
