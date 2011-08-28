(function() {
  var app, coffee, express, io, nko, states;
  express = require('express');
  nko = require('nko')('Z6+o2A6kn7+tCofT');
  coffee = require('coffee-script');
  app = module.exports = express.createServer();
  io = require('socket.io').listen(app);
  app.configure(function() {
    app.set('views', __dirname + '/views');
    app.set('view engine', 'jade');
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(app.router);
    app.use(express.compiler({
      src: __dirname + '/src',
      dest: __dirname + '/public/javascripts',
      enable: ['coffeescript']
    }));
    return app.use(express.static(__dirname + '/public'));
  });
  app.configure('development', function() {
    return app.use(express.errorHandler({
      dumpExceptions: true,
      showStack: true
    }));
  });
  app.configure('production', function() {
    return app.use(express.errorHandler());
  });
  app.get('/:id?', function(req, res) {
    return res.render('index', {
      title: 'Phon'
    });
  });
  states = {
    main: "main state",
    "default": "default state"
  };
  io.sockets.on('connection', function(socket) {
    socket.emit('connection');
    socket.on('room', function(id, callback) {
      var state;
      if (id === "") {
        id = "main";
      }
      console.log("got client in room: " + id);
      if (states[id] != null) {
        state = states[id];
      } else {
        state = 'empty!';
      }
      socket.join(id);
      return socket.set('roomId', id, function() {
        return socket.emit('init', state);
      });
    });
    socket.on('cell', function(cell_properties) {
      return socket.get('roomId', function(err, id) {
        return io.sockets["in"](id).emit('cell', cell_properties);
      });
    });
    socket.on('wall', function(data) {
      return socket.get('roomId', function(err, id) {
        return io.sockets["in"](id).emit('wall', data);
      });
    });
    socket.on('chat', function(msg) {
      return socket.get('roomId', function(err, id) {
        return io.sockets["in"](id).emit('chat', msg);
      });
    });
    return socket.on('effect', function(parameters) {
      return socket.get('roomId', function(err, id) {
        return io.sockets["in"](id).emit('effect', parameters);
      });
    });
  });
  app.listen(parseInt(process.env.PORT) || 3000);
  console.log("Listening on " + (app.address().port));
}).call(this);
