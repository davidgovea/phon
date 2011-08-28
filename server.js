(function() {
  var app, coffee, express, io, nko;
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
  app.get('/', function(req, res) {
    return res.render('index', {
      title: 'Phon'
    });
  });
  io.sockets.on('connection', function(socket) {
    socket.emit('state', {
      data: 'phon state'
    });
    socket.on('cell', function(data) {
      return console.log(data);
    });
    socket.on('wall', function(data) {
      return console.log(data);
    });
    return socket.on('chat', function(msg) {
      return io.sockets.emit('chat', msg);
    });
  });
  app.listen(parseInt(process.env.PORT) || 3000);
  console.log("Listening on " + (app.address().port));
}).call(this);
