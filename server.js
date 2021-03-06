(function() {
  var app, beatLength, coffee, express, getActiveCells, getWallIndex, getWalls, io, iterateEmitters, statemachine, states;
  beatLength = 200;
  express = require('express');
  coffee = require('coffee-script');
  app = module.exports = express.createServer();
  io = require('socket.io').listen(app);
  statemachine = require('./statemachine');
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
    main: {
      cells: statemachine.init(),
      walls: {},
      emitters: statemachine.emitters(),
      effects: {
        'reverb': 0,
        'bitcrusher': 0
      }
    }
  };
  console.log(states.main.cells);
  getActiveCells = function(stateid) {
    var active, cell, index, state, _ref;
    active = [];
    state = states[stateid];
    _ref = state.cells;
    for (index in _ref) {
      cell = _ref[index];
      if (cell.active) {
        active.push({
          index: index,
          sound: cell.sound
        });
      }
    }
    console.log("--------------------");
    console.log(active);
    return active;
  };
  getWallIndex = function(row1, col1, row2, col2) {
    var coldiff, order, rowdiff, upperCol, upperRow;
    rowdiff = row1 - row2;
    coldiff = col1 - col2;
    if (col1 >= col2) {
      upperCol = col1;
      order = [row1, col1, row2, col2];
    } else {
      upperCol = col2;
      order = [row2, col2, row1, col1];
    }
    if (row1 >= row2) {
      upperRow = row1;
      if (row1 !== row2) {
        order = [row1, col1, row2, col2];
      }
    } else {
      upperRow = row2;
      order = [row2, col2, row1, col1];
    }
    return "" + order[0] + "_" + order[1] + "_" + order[2] + "_" + order[3];
  };
  getWalls = function(stateid) {
    var index, state, wall, walls, _ref;
    walls = [];
    state = states[stateid];
    _ref = state.walls;
    for (index in _ref) {
      wall = _ref[index];
      if (wall) {
        walls.push(index);
      }
    }
    return walls;
  };
  iterateEmitters = function() {
    var emitter, key, name, state, _len, _len2, _ref;
    for (state = 0, _len = states.length; state < _len; state++) {
      name = states[state];
      _ref = state.emitters;
      for (emitter = 0, _len2 = _ref.length; emitter < _len2; emitter++) {
        key = _ref[emitter];
        emitter.index = (emitter.index + 1) % emitter.life;
      }
    }
    return setTimeout(iterateEmitters, beatLength);
  };
  io.sockets.on('connection', function(socket) {
    socket.once('connect');
    socket.on('room', function(id, callback) {
      var state;
      if (id === "") {
        id = "main";
      }
      console.log("got client in room: " + id);
      if (states[id] != null) {
        state = states[id];
      } else {
        state = {
          cells: statemachine.init(),
          walls: {},
          emitters: statemachine.emitters(),
          effects: {
            'reverb': 0,
            'bitcrusher': 0
          }
        };
        states[id] = state;
      }
      socket.join(id);
      return socket.set('roomId', id, function() {
        return socket.emit('init', {
          cells: getActiveCells(id),
          walls: getWalls(id),
          emitters: state.emitters,
          effects: state.effects
        });
      });
    });
    socket.on('effect', function(params) {
      console.log(params);
      return socket.get('roomId', function(err, id) {
        var state;
        state = states[id];
        state.effects[params.type] += params.amount;
        return io.sockets["in"](id).emit('effect', params);
      });
    });
    socket.on('cell', function(cell_properties) {
      console.log(cell_properties);
      return socket.get('roomId', function(err, id) {
        var cell, index;
        io.sockets["in"](id).emit('cell', cell_properties);
        index = "" + cell_properties.row + "_" + cell_properties.col + "_1";
        cell = states[id].cells[index];
        if (cell_properties.sound !== null) {
          cell.active = true;
          return cell.sound = cell_properties.sound;
        } else {
          cell.active = false;
          return cell.sound = null;
        }
      });
    });
    socket.on('wall', function(data) {
      return socket.get('roomId', function(err, id) {
        var pts;
        switch (data.action) {
          case 'del':
            states[id].walls[data.index] = null;
            break;
          case 'split':
          case 'add':
            pts = data.points;
            states[id].walls[getWallIndex(pts[0][0], pts[0][1], pts[1][0], pts[1][1])] = true;
        }
        return io.sockets["in"](id).emit('wall', data);
      });
    });
    return socket.on('chat', function(msg) {
      return socket.get('roomId', function(err, id) {
        return io.sockets["in"](id).emit('chat', msg);
      });
    });
  });
  app.listen(parseInt(process.env.PORT) || 3000);
  console.log("Listening on " + (app.address().port));
}).call(this);
