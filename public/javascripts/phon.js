(function() {
  var CELL_SIZE, Cell, Emitter, NUM_COLS, NUM_ROWS, Particle, Sound, StateHash, cell_colors, cells, collide, decays, doLoop, emitterHash, emitter_counter, emitter_counter2, emitter_counter3, emitter_every, emitter_periods, init, iterate, log, note_color, occupied, paper, particle_color, particles, processSplit, select_color, server, socket, vector, wallList, wall_color;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  window.Phon = {};
  Phon.Properties = {
    tick: 200,
    roomId: document.location.pathname.substring(1)
  };
  Phon.Elements = {};
  $(function() {
    return Phon.Elements.$paper = $('#paper');
  });
  Phon.Socket = io.connect(document.location.protocol + '//' + document.location.host);
  Phon.Socket.on('connect', function() {
    if (paper === null) {
      init();
      vector.init();
    }
    return Phon.Socket.emit("room", Phon.Properties.roomId);
  });
  Phon.Socket.on('init', function(data) {
    var cell, emit, key, rc, wallIndex, walls, _i, _j, _len, _len2, _len3, _ref, _ref2;
    console.log(data);
    walls = data.walls;
    for (_i = 0, _len = walls.length; _i < _len; _i++) {
      wallIndex = walls[_i];
      rc = wallIndex.split("_");
      vector.addWall(rc[0], rc[1], rc[2], rc[3]);
    }
    _ref = data.emitters;
    for (emit = 0, _len2 = _ref.length; emit < _len2; emit++) {
      key = _ref[emit];
      emitterHash[key].setIndex(emitter.index);
    }
    _ref2 = data.cells;
    for (_j = 0, _len3 = _ref2.length; _j < _len3; _j++) {
      cell = _ref2[_j];
      cells[cell.index].active = true;
      cells[cell.index].sound = cell.sound;
    }
    return doLoop();
  });
  Phon.Socket.on('cell', function(cell_properties) {
    var cell;
    console.log(cell_properties);
    cell = cells["" + cell_properties.row + "_" + cell_properties.col + "_1"];
    cell.setActive(true);
    return cell.addSound(cell_properties.sound);
  });
  NUM_ROWS = 18;
  NUM_COLS = 24;
  CELL_SIZE = 28;
  cells = {};
  wallList = {};
  particles = [];
  occupied = null;
  paper = null;
  cell_colors = {
    1: "#8A8A8A",
    2: "#616161"
  };
  particle_color = "#52C8FF";
  select_color = "#00AEFF";
  wall_color = '#1ED233';
  note_color = "#E61D5F";
  log = function(msg) {
    return console.log(msg);
  };
  Phon.Sounds = {};
  Sound = (function() {
    __extends(_Class, Backbone.Model);
    function _Class() {
      _Class.__super__.constructor.apply(this, arguments);
    }
    _Class.prototype.register = function(row, col) {
      return Phon.Socket.emit('cell', {
        row: row,
        col: col,
        sound: this.attributes
      });
    };
    return _Class;
  })();
  Phon.Sounds.Lead = (function() {
    __extends(_Class, Sound);
    function _Class() {
      _Class.__super__.constructor.apply(this, arguments);
    }
    _Class.prototype.defaults = {
      type: 'Lead',
      pitch: 'a',
      length: 0
    };
    return _Class;
  })();
  Phon.Sounds.Bass = (function() {
    __extends(_Class, Sound);
    function _Class() {
      _Class.__super__.constructor.apply(this, arguments);
    }
    _Class.prototype.defaults = {
      type: 'Bass',
      pitch: 'a',
      length: 0
    };
    return _Class;
  })();
  Phon.Sounds.Drum = (function() {
    __extends(_Class, Sound);
    function _Class() {
      _Class.__super__.constructor.apply(this, arguments);
    }
    _Class.prototype.defaults = {
      type: 'Drum',
      pitch: 0,
      offset: 0,
      sample: 'kick'
    };
    return _Class;
  })();
  Phon.Sounds.Sample = (function() {
    __extends(_Class, Sound);
    function _Class() {
      _Class.__super__.constructor.apply(this, arguments);
    }
    _Class.prototype.defaults = {
      type: 'Sample',
      pitch: 0,
      offset: 0,
      sample: 'snare'
    };
    return _Class;
  })();
  Raphael.fn.octagon = function(x, y, side, side_rad) {
    var p;
    p = this.path("M" + (x + side_rad) + " " + y + "l" + side + " 0l" + side_rad + " " + side_rad + "l0 " + side + "l" + (-side_rad) + " " + side_rad + "l" + (-side) + " 0l" + (-side_rad) + " " + (-side_rad) + "l0 " + (-side) + "l" + side_rad + " " + (-side_rad) + "z");
    return p;
  };
  Raphael.fn.octogrid = function(x, y, rows, cols, width) {
    var Diamond, Oct, cell, col, diamond, raph, row, side, side_rad, startx, starty;
    console.time('octogrid');
    side = width / (1 + Math.SQRT2);
    side_rad = side / Math.SQRT2;
    startx = x;
    starty = y;
    raph = this;
    Oct = (function() {
      function Oct(x, y, side, side_rad, row, col) {
        this.row = row;
        this.col = col;
        this.onDblClick = __bind(this.onDblClick, this);
        this.onClick = __bind(this.onClick, this);
        this.shape = raph.octagon(x, y, side, side_rad);
        this.shape.click(this.onClick);
        this.shape.dblclick(this.onDblClick);
      }
      Oct.prototype.row = 0;
      Oct.prototype.col = 0;
      Oct.prototype.onClick = function(evt) {
        return cells["" + this.row + "_" + this.col + "_1"].select();
      };
      Oct.prototype.onDblClick = function(evt) {};
      return Oct;
    })();
    Diamond = (function() {
      function Diamond(x, y, side, row, col) {
        this.row = row;
        this.col = col;
        this.dragUp = __bind(this.dragUp, this);
        this.dragMove = __bind(this.dragMove, this);
        this.dragStart = __bind(this.dragStart, this);
        this.shape = raph.rect(x - side / 2, y - side / 2, side, side);
        this.shape.center = [x, y];
        this.shape.rotate(45);
        this.shape.drag(this.dragMove, this.dragStart, this.dragUp);
      }
      Diamond.prototype.row = 0;
      Diamond.prototype.col = 0;
      Diamond.prototype.dragLine = null;
      Diamond.prototype.dragStart = function() {
        return this.shape.attr({
          opacity: 0.5
        });
      };
      Diamond.prototype.dragMove = function(x, y) {
        var line, pathString, target;
        if (Math.abs(x) > width * .6 || Math.abs(y) > width * .6) {
          target = this.getAngle(x, y);
          if (this.row === 1 && (target === 5 || target === 6 || target === 7)) {
            return false;
          } else if (this.col === 1 && (target === 3 || target === 4 || target === 5)) {
            return false;
          } else if (this.row === (rows - 1) && (target === 1 || target === 2 || target === 3)) {
            return false;
          } else if (this.col === (cols - 1) && (target === 0 || target === 1 || target === 7)) {
            return false;
          } else {
            line = this.neighbors[target];
          }
          pathString = "M" + (this.shape.attrs.x + this.shape.attrs.height / 2) + " " + (this.shape.attrs.y + this.shape.attrs.height / 2) + "l" + (line[0] * (width + 3)) + " " + (line[1] * (width + 3));
          if (this.dragLine != null) {
            this.dragLine.animate({
              path: pathString
            }, 20);
          } else {
            this.dragLine = this.shape.paper.path(pathString);
          }
          this.dragLine.valid = true;
          this.dragLine.line = line;
        } else {
          pathString = "M" + (this.shape.attrs.x + this.shape.attrs.height / 2) + " " + (this.shape.attrs.y + this.shape.attrs.height / 2) + "l" + x + " " + y;
          if (this.dragLine != null) {
            this.dragLine.animate({
              path: pathString
            }, 20);
          } else {
            this.dragLine = this.shape.paper.path(pathString);
          }
          this.dragLine.valid = false;
        }
        return this.dragLine.attr('stroke-width', 5);
      };
      Diamond.prototype.dragUp = function() {
        var col2, row2;
        if (this.dragLine != null) {
          if (this.dragLine.valid) {
            row2 = this.row + this.dragLine.line[1];
            col2 = this.col + this.dragLine.line[0];
            if (this.dragLine.line[0] === this.dragLine.line[1] || this.dragLine.line[0] === this.dragLine.line[1]) {
              Phon.Socket.emit('wall', {
                action: 'split',
                points: [[this.row, this.col], [row2, col2]]
              });
            } else {
              Phon.Socket.emit('wall', {
                action: 'add',
                points: [[this.row, this.col], [row2, col2]]
              });
            }
            vector.addWall(this.row, this.col, row2, col2, true);
          }
          this.dragLine.remove();
          this.dragLine = null;
        }
        return this.shape.attr({
          opacity: 1
        });
      };
      Diamond.prototype.getAngle = function(x, y) {
        var atan, i, inc, target;
        i = 1;
        target = 0;
        atan = Math.atan(y / x) / (Math.PI / 180);
        inc = 22.5;
        if (x < 0) {
          atan += 180;
        } else if (y < 0) {
          atan += 360;
        }
        while (i * inc < atan) {
          target += 1;
          i += 2;
        }
        if (target > 7) {
          return target % 8;
        } else {
          return target;
        }
      };
      Diamond.prototype.neighbors = {
        0: [1, 0],
        1: [1, 1],
        2: [0, 1],
        3: [-1, 1],
        4: [-1, 0],
        5: [-1, -1],
        6: [0, -1],
        7: [1, -1]
      };
      return Diamond;
    })();
    for (row = 0; 0 <= rows ? row < rows : row > rows; 0 <= rows ? row++ : row--) {
      x = startx;
      for (col = 0; 0 <= cols ? col < cols : col > cols; 0 <= cols ? col++ : col--) {
        cell = new Oct(x, y, side, side_rad, row + 1, col + 1);
        cell.shape.attr({
          fill: cell_colors[1]
        });
        cells["" + (row + 1) + "_" + (col + 1) + "_1"].shape = cell.shape;
        if (!(row === 0 || col === 0)) {
          diamond = new Diamond(x - 1.5, y - 1.5, side, row, col);
          diamond.shape.attr('fill', cell_colors[2]);
          cells["" + row + "_" + col + "_2"].shape = diamond.shape;
        }
        x += width + 3;
      }
      y += width + 3;
    }
    return console.timeEnd('octogrid');
  };
  vector = {
    init: function() {
      paper = Raphael("paper", (NUM_COLS + 2) * (CELL_SIZE + 3), (NUM_ROWS + 2) * (CELL_SIZE + 3));
      return paper.octogrid(1, 1, NUM_ROWS, NUM_COLS, CELL_SIZE);
    },
    addWall: function(row1, col1, row2, col2, pending) {
      var cell, cell1, cell2, coldiff, index, info, line, order, rowdiff, toSplit, upperCol, upperRow, walls, _ref, _ref2;
      if (pending == null) {
        pending = false;
      }
      cell1 = cells["" + row1 + "_" + col1 + "_2"];
      cell2 = cells["" + row2 + "_" + col2 + "_2"];
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
      line = paper.path("M" + cell1.shape.center[0] + " " + cell1.shape.center[1] + "L" + cell2.shape.center[0] + " " + cell2.shape.center[1]);
      cell1.shape.toFront();
      cell2.shape.toFront();
      index = "" + order[0] + "_" + order[1] + "_" + order[2] + "_" + order[3];
      line.index = index;
      if ((_ref = wallList[index]) != null) {
        _ref.remove();
      }
      wallList[index] = line;
      if (pending) {
        line.attr({
          'stroke-width': '3',
          'stroke-dasharray': ".",
          stroke: wall_color
        });
        return setTimeout(function() {
          return line.remove();
        }, 3000);
      } else {
        line.attr({
          'stroke-width': '6',
          stroke: wall_color
        });
        line.dblclick(function() {
          Phon.Socket.emit('wall', {
            action: 'del',
            index: line.index
          });
          return log(line.index);
        });
        if (rowdiff === coldiff) {
          toSplit = [upperRow, upperCol, 1];
        } else if (rowdiff === -coldiff) {
          toSplit = [upperRow, upperCol, 2];
        } else if (rowdiff === 0) {
          walls = [[upperRow, upperCol, 2], [upperRow + 1, upperCol, 8]];
        } else {
          walls = [[upperRow, upperCol, 1], [upperRow, upperCol + 1, 4]];
        }
        if (toSplit != null) {
          cell = cells["" + toSplit[0] + "_" + toSplit[1] + "_1"];
          if ((_ref2 = cell.splitLine) != null) {
            _ref2.remove();
          }
          cell.split = toSplit[2];
          cell.splitLine = line;
          return line.info = {
            type: 'split',
            cell: toSplit
          };
        } else if (walls != null) {
          info = {
            type: 'wall',
            cells: []
          };
          walls.forEach(function(c) {
            var _ref3;
            if ((_ref3 = cells["" + c[0] + "_" + c[1] + "_1"]) != null) {
              _ref3.walls += c[2];
            }
            return info.cells.push(c);
          });
          return line.info = info;
        }
      }
    }
  };
  Particle = (function() {
    function Particle(row, col, state, direction, lifetime) {
      this.row = row;
      this.col = col;
      this.state = state;
      this.direction = direction;
      this.lifetime = lifetime != null ? lifetime : 32;
    }
    Particle.prototype.excited = 0;
    Particle.prototype.excite = function() {
      return this.excited = 1;
    };
    Particle.prototype.decay = function() {
      return this.excited = 0;
    };
    Particle.prototype.kill = function() {
      return this.lifetime = 0;
    };
    Particle.prototype.move = function() {
      if (this.state === 1) {
        if (!this.excited) {
          switch (this.direction) {
            case 1:
              this.col++;
              break;
            case 2:
              this.row++;
              break;
            case 4:
              this.col--;
              break;
            case 8:
              this.row--;
              break;
            default:
              throw new Error("Don't know where to go! Normal particle: [" + this.row + "," + this.col + "], direction " + this.direction);
          }
        } else {
          switch (this.direction) {
            case 1:
              break;
            case 4:
              this.col--;
              break;
            case 16:
              this.row--;
              this.col--;
              break;
            case 64:
              this.row--;
              break;
            default:
              throw new Error("Don't know where to go! Energetic particle, normal space: [" + this.row + "," + this.col + "], direction " + this.direction);
          }
          this.state = 2;
        }
      } else {
        switch (this.direction) {
          case 1:
            this.row++;
            this.col++;
            break;
          case 4:
            this.row++;
            break;
          case 16:
            break;
          case 64:
            this.col++;
        }
        this.state = 1;
      }
      if (this.lifetime > 0) {
        return this.lifetime--;
      }
    };
    Particle.prototype.reverse = function() {
      if (!this.excited) {
        this.direction = this.direction << 2;
        if (this.direction > 8) {
          return this.direction = this.direction >> 4;
        }
      } else {
        this.direction = this.direction << 4;
        if (this.direction > 64) {
          return this.direction = this.direction >> 8;
        }
      }
    };
    Particle.prototype.splitReverse = function(splitMode) {
      var results;
      results = {
        1: {
          1: 2,
          8: 4,
          4: 8,
          2: 1,
          excited: {
            1: 1,
            16: 16,
            64: 4,
            4: 64
          }
        },
        2: {
          1: 8,
          2: 4,
          4: 2,
          8: 1,
          excited: {
            4: 4,
            64: 64,
            16: 1,
            1: 16
          }
        }
      }[splitMode];
      this.direction = this.excited ? results.excited[this.direction] : results[this.direction];
      if (this.excited) {
        return this.direction = results.excited[this.direction];
      } else {

      }
    };
    Particle.prototype.checkObstacles = function(repeat, split) {
      if (repeat == null) {
        repeat = false;
      }
      if (split == null) {
        split = 0;
      }
      if (!this.excited) {
        if ((this.row === 1 && this.direction === 8) || (this.row === NUM_ROWS && this.direction === 2) || (this.col === 1 && this.direction === 4) || (this.col === NUM_COLS && this.direction === 1)) {
          if (!repeat) {
            this.reverse();
            if (split) {
              this.splitReverse(split);
            }
            return this.checkObstacles(true);
          } else {
            return this.lifetime = 0;
          }
        } else if (cells["" + this.row + "_" + this.col + "_1"].walls & this.direction) {
          if (!repeat) {
            this.reverse();
            if (split) {
              this.splitReverse(split);
            }
            return this.checkObstacles(true);
          } else {
            return this.lifetime = 0;
          }
        }
      } else if (this.state === 1) {
        if ((this.row === 1 && (this.direction === 16 || this.direction === 64)) || (this.row === NUM_ROWS && (this.direction === 1 || this.direction === 4)) || (this.col === 1 && (this.direction === 4 || this.direction === 16)) || (this.col === NUM_COLS && (this.direction === 1 || this.direction === 64))) {
          this.reverse();
          if (split) {
            return this.splitReverse(split);
          }
        }
      }
    };
    return Particle;
  })();
  Cell = (function() {
    function Cell(row, col, state) {
      this.row = row;
      this.col = col;
      this.state = state;
    }
    Cell.prototype.split = false;
    Cell.prototype.walls = 0;
    Cell.prototype.active = false;
    Cell.prototype.shape = null;
    Cell.prototype.sound = false;
    Cell.prototype.addSound = function(sound) {
      this.activate();
      return this.sound = sound;
    };
    Cell.prototype.removeSound = function() {
      this.setActive(false);
      return this.sound = null;
    };
    Cell.prototype.activate = function(sound) {
      this.active = true;
      this.sound = sound;
      return this.shape.attr({
        fill: "#0f0"
      });
    };
    Cell.prototype.deactivate = function() {
      this.active = false;
      return this.shape.attr({
        fill: cell_colors[this.state]
      });
    };
    Cell.prototype.setInstrument = function(parameters) {};
    Cell.prototype.select = function(state) {
      if (state == null) {
        state = true;
      }
      if (state) {
        if (cells.selected != null) {
          cells.selected.select(false);
        }
        this.shape.attr({
          stroke: select_color,
          'stroke-width': 4
        });
        cells.selected = this;
        return Phon.Elements.$paper.trigger('cell-selected', [this]);
      } else {
        return this.shape.attr({
          stroke: "#000",
          'stroke-width': 1
        });
      }
    };
    Cell.prototype.activate = function() {};
    Cell.prototype.deactivate = function() {};
    Cell.prototype.setInstrument = function(parameters) {};
    Cell.prototype.setActive = function(state) {
      if (state == null) {
        state = true;
      }
      if (state === true) {
        this.shape.attr({
          fill: note_color
        });
      } else {
        this.shape.attr({
          fill: cell_colors[this.state]
        });
      }
      return this.active = state;
    };
    Cell.prototype.occupy = function(state) {
      if (state === true) {
        return this.shape.attr({
          fill: particle_color
        });
      } else if (this.active) {
        return this.shape.attr({
          fill: note_color
        });
      } else {
        return this.shape.attr({
          fill: cell_colors[this.state]
        });
      }
    };
    return Cell;
  })();
  emitterHash = {};
  emitter_every = 7;
  emitter_periods = [8, 16, 32, 16];
  emitter_counter = 0;
  emitter_counter2 = 0;
  emitter_counter3 = Math.floor(emitter_every / 2);
  Emitter = (function() {
    function Emitter(row, col, period, direction) {
      this.row = row;
      this.col = col;
      this.period = period;
      this.direction = direction;
    }
    Emitter.prototype.index = 0;
    Emitter.prototype.step = function() {
      this.index++;
      if (this.index === this.period) {
        this.index = 0;
        return this.emit();
      }
    };
    Emitter.prototype.setIndex = function(num) {
      return this.index = num % this.period;
    };
    Emitter.prototype.emit = function() {
      var particle;
      particle = new Particle(this.row, this.col, 1, this.direction);
      occupied.add(particle);
      return particles.push(particle);
    };
    return Emitter;
  })();
  StateHash = (function() {
    function StateHash() {
      this.h = {};
      this.lastBeat = [];
      this.thisBeat = [];
    }
    StateHash.prototype.add = function(particle) {
      var dir, index;
      index = "" + particle.row + "_" + particle.col + "_" + particle.state;
      if (!this.h[index]) {
        this.h[index] = cells[index];
        this.h[index].particles = [];
        this.h[index].sums = [0, 0];
        this.thisBeat.push(index);
      }
      if (this.h[index].split) {
        dir = particle.direction;
        this.h[index].sums = [0, 0, 0, 0];
        if (this.h[index].split === 1) {
          if (!(particle.excited === 1 && (dir === 1 || dir === 16))) {
            if (dir === 1 || dir === 8 || dir === 64) {
              this.h[index].sums[particle.excited] += dir;
            } else {
              this.h[index].sums[2 + particle.excited] += dir;
            }
          }
        } else {
          if (!(particle.excited === 1 && (dir === 4 || dir === 64))) {
            if (dir === 1 || dir === 2) {
              this.h[index].sums[particle.excited] += dir;
            } else {
              this.h[index].sums[2 + particle.excited] += dir;
            }
          }
        }
      } else {
        this.h[index].sums[particle.excited] += particle.direction;
      }
      return this.h[index].particles.push(particle);
    };
    StateHash.prototype.reset = function() {
      this.h = {};
      this.lastBeat = this.thisBeat;
      return this.thisBeat = [];
    };
    return StateHash;
  })();
  Array.prototype.shuffle = function() {
    return this.sort(function() {
      return 0.5 - Math.random();
    });
  };
  decays = {
    single: function() {
      return Math.random() * 100 < 50;
    },
    pair: function() {
      return Math.random() * 100 < 50;
    },
    headon: function() {
      return Math.random() * 100 < 15;
    }
  };
  init = function() {
    var col, period, row, _results;
    occupied = new StateHash;
    _results = [];
    for (row = 1; 1 <= NUM_ROWS ? row <= NUM_ROWS : row >= NUM_ROWS; 1 <= NUM_ROWS ? row++ : row--) {
      if (row === 1) {
        emitter_counter = 0;
      } else if (row === NUM_ROWS) {
        emitter_counter = Math.floor(emitter_every / 2);
      }
      _results.push((function() {
        var _results2;
        _results2 = [];
        for (col = 1; 1 <= NUM_COLS ? col <= NUM_COLS : col >= NUM_COLS; 1 <= NUM_COLS ? col++ : col--) {
          cells["" + row + "_" + col + "_1"] = new Cell(row, col, 1);
          if (!(row === NUM_ROWS || col === NUM_COLS)) {
            cells["" + row + "_" + col + "_2"] = new Cell(row, col, 2);
          }
          _results2.push(row === 1 ? (emitter_counter++, emitter_counter === emitter_every ? (emitter_counter = 0, period = emitter_periods.shift(), emitterHash["" + row + "_" + col] = new Emitter(row, col, period, 2), emitter_periods.push(period)) : void 0) : row === NUM_ROWS ? (emitter_counter++, emitter_counter === emitter_every ? (emitter_counter = 0, period = emitter_periods.shift(), emitterHash["" + row + "_" + col] = new Emitter(row, col, period, 8), emitter_periods.push(period)) : void 0) : col === 1 ? (emitter_counter2++, emitter_counter2 === emitter_every ? (emitter_counter2 = 0, period = emitter_periods.shift(), emitterHash["" + row + "_" + col] = new Emitter(row, col, period, 1), emitter_periods.push(period)) : void 0) : col === NUM_COLS ? (emitter_counter3++, emitter_counter3 === emitter_every ? (emitter_counter3 = 0, period = emitter_periods.shift(), emitterHash["" + row + "_" + col] = new Emitter(row, col, period, 4), emitter_periods.push(period)) : void 0) : void 0);
        }
        return _results2;
      })());
    }
    return _results;
  };
  iterate = function() {
    var cell, cellIndex, emit, emitIndex, particle, toKill, _i, _len, _ref;
    occupied.reset();
    toKill = [];
    for (_i = 0, _len = particles.length; _i < _len; _i++) {
      particle = particles[_i];
      if (particle.lifetime === 0) {
        toKill.push(particle);
      } else {
        particle.move();
        occupied.add(particle);
      }
    }
    if (toKill.length > 0) {
      toKill.forEach(function(p) {
        return particles.splice(particles.indexOf(p), 1);
      });
    }
    for (emitIndex in emitterHash) {
      emit = emitterHash[emitIndex];
      emit.step();
    }
    _ref = occupied.h;
    for (cellIndex in _ref) {
      cell = _ref[cellIndex];
      if (cell.state === 1) {
        if (cell.split) {
          processSplit(cell.split, cell.sums, cell.particles);
          cell.particles.forEach(function(p) {
            return p.checkObstacles(false, cell.split);
          });
        } else {
          if (cell.sums[1] || cell.particles.length > 1) {
            collide(cell.sums, cell.particles);
          }
          cell.particles.forEach(function(p) {
            return p.checkObstacles();
          });
        }
        if (cell.active) {
          log(cell);
          log("TODO / record note playback info");
        }
      }
    }
    return {
      "this": occupied.thisBeat,
      last: occupied.lastBeat
    };
  };
  processSplit = function(split, sums, particles) {
    var eSum1, eSum2, nSum1, nSum2;
    nSum1 = sums[0];
    eSum1 = sums[1];
    nSum2 = sums[2];
    eSum2 = sums[3];
    switch (split) {
      case 1:
        switch (nSum1) {
          case 1:
          case 8:
            switch (eSum1) {
              case 0:
                particles.forEach(function(p) {
                  if (p.direction === 1 || p.direction === 8) {
                    return p.splitReverse(split);
                  }
                });
                break;
              case 64:
                break;
              case 128:
            }
            break;
          case 9:
        }
        switch (nSum2) {
          case 2:
          case 4:
            switch (eSum2) {
              case 0:
                return particles.forEach(function(p) {
                  if (p.direction === 2 || p.direction === 4) {
                    return p.splitReverse(split);
                  }
                });
              case 4:
                break;
              case 8:
            }
            break;
          case 6:
        }
        break;
      case 2:
        switch (nSum1) {
          case 1:
          case 2:
            switch (eSum1) {
              case 0:
                particles.forEach(function(p) {
                  if (p.direction === 1 || p.direction === 2) {
                    return p.splitReverse(split);
                  }
                });
                break;
              case 1:
                break;
              case 2:
            }
            break;
          case 3:
        }
        switch (nSum2) {
          case 4:
          case 8:
            switch (eSum2) {
              case 0:
                return particles.forEach(function(p) {
                  if (p.direction === 4 || p.direction === 8) {
                    return p.splitReverse(split);
                  }
                });
              case 16:
                break;
              case 64:
            }
            break;
          case 12:
        }
    }
  };
  collide = function(sums, particles) {
    var dir, dirs, eSum, nSum, result;
    nSum = sums[0];
    eSum = sums[1];
    console.time('find');
    switch (nSum) {
      case 0:
        switch (eSum) {
          case 1:
          case 4:
          case 16:
          case 64:
            if (decays.single()) {
              dirs = {
                1: [1, 2],
                4: [2, 4],
                16: [4, 8],
                64: [8, 1]
              }[eSum].shuffle();
              particles.forEach(function(p) {
                p.decay();
                return p.direction = dirs.shift();
              });
            }
            return true;
          case 2:
          case 8:
          case 32:
          case 128:
            if (decays.pair()) {
              dirs = {
                2: [1, 2],
                8: [2, 4],
                32: [4, 8],
                128: [8, 1]
              }[eSum].shuffle();
              particles.forEach(function(p) {
                p.decay();
                return p.direction = dirs.shift();
              });
            }
            return true;
          case 17:
          case 64:
            dirs = [[2, 8], [1, 4]].shuffle().shift().shuffle();
            return true;
          default:
            particles.forEach(function(p) {});
            return false;
        }
        break;
      case 1:
      case 4:
      case 8:
      case 16:
        switch (eSum) {
          case 1:
          case 4:
          case 16:
          case 64:
            return true;
          case 2:
          case 8:
          case 32:
          case 128:
            return true;
        }
        break;
      case 5:
      case 10:
        switch (eSum) {
          case 0:
            particles.forEach(function(p) {
              return p.reverse();
            });
            return true;
        }
        break;
      case 3:
      case 6:
      case 9:
      case 12:
        switch (eSum) {
          case 0:
            dir = {
              3: 1,
              6: 4,
              9: 64,
              12: 16
            }[nSum];
            particles.forEach(function(p) {
              p.excite();
              return p.direction = dir;
            });
            return true;
        }
        break;
      case 7:
      case 11:
      case 13:
      case 14:
        switch (eSum) {
          case 0:
            result = {
              7: {
                kill: 2,
                dir: {
                  4: 4,
                  1: 1
                }
              },
              11: {
                kill: 1,
                dir: {
                  2: 1,
                  8: 64
                }
              },
              13: {
                kill: 8,
                dir: {
                  1: 64,
                  4: 16
                }
              },
              14: {
                kill: 4,
                dir: {
                  8: 16,
                  2: 4
                }
              }
            }[nSum];
            particles.forEach(function(p) {
              p.excite();
              if (p.direction === result.kill) {
                return p.kill();
              } else {
                return p.direction = result.dir[p.direction];
              }
            });
            return true;
        }
        break;
      case 15:
        switch (eSum) {
          case 0:
            dirs = [1, 4, 16, 64].shuffle();
            particles.forEach(function(p) {
              p.econsoxcite();
              return p.direction = dirs.shift();
            });
            return true;
        }
    }
  };
  $(function() {
    var ChatModel, ChatView, MessageCollection, MessageModel, Module, Modules, SidebarModel, SidebarView;
    Modules = {};
    Module = (function() {
      __extends(_Class, Backbone.Model);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.defaults = {
        closed: true,
        sound: false
      };
      return _Class;
    })();
    Modules.Instrument = (function() {
      __extends(_Class, Module);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.initialize = function(options) {
        return this.refresh_gui();
      };
      _Class.prototype.refresh_gui = function() {
        var gui, sound;
        sound = this.get('sound');
        gui = new DAT.GUI;
        gui.add(sound.attributes, 'pitch').options('a', 'a#', 'b', 'c', 'c#', 'd', 'd#', 'e', 'f', 'f#', 'g');
        gui.add(sound.attributes, 'length').min(0).max(100);
        return this.gui_elements = [gui.domElement];
      };
      return _Class;
    })();
    Modules.Sample = (function() {
      __extends(_Class, Module);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.initialize = function() {
        return this.refresh_gui();
      };
      _Class.prototype.refresh_gui = function() {
        var gui, sound;
        sound = this.get('sound');
        gui = new DAT.GUI;
        gui.add(sound.attributes, 'sample').options('kick', 'snare');
        gui.add(sound.attributes, 'pitch').min(0).max(440);
        gui.add(sound.attributes, 'offset').min(0).max(100);
        return this.gui_elements = [gui.domElement];
      };
      return _Class;
    })();
    Modules.Global = (function() {
      __extends(_Class, Backbone.Model);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.defaults = {
        closed: false
      };
      _Class.prototype.initialize = function() {
        var $titles, bitcrusher, gui1, gui2, notify_grid, reverb;
        notify_grid = function(type, amount) {
          return Phon.Socket.emit('effect', {
            type: type,
            amount: amount
          });
        };
        $titles = {};
        $titles.reverb = $('<h3>Reverb</h3>');
        $titles.bitcrusher = $('<h3>Bitcrusher</h3>');
        Phon.Socket.on('effect', function(params) {
          var $notify, amount, count;
          amount = params.amount;
          count = amount > 0 ? "+" + amount : amount;
          $notify = $('<span class="notify" />').text(count);
          $titles[params.type].append($notify);
          return setTimeout(function() {
            return $notify.fadeOut(function() {
              return $notify.remove();
            });
          }, 1500);
        });
        reverb = {
          more: function() {
            return notify_grid('reverb', 1);
          },
          less: function() {
            return notify_grid('reverb', -1);
          }
        };
        bitcrusher = {
          more: function() {
            return notify_grid('bitcrusher', 1);
          },
          less: function() {
            return notify_grid('bitcrusher', -1);
          }
        };
        gui1 = new DAT.GUI;
        gui1.add(reverb, 'more');
        gui1.add(reverb, 'less');
        gui2 = new DAT.GUI;
        gui2.add(bitcrusher, 'more');
        gui2.add(bitcrusher, 'less');
        return this.gui_elements = [$titles.reverb, gui1.domElement, $titles.bitcrusher, gui2.domElement];
      };
      return _Class;
    })();
    SidebarModel = (function() {
      __extends(_Class, Backbone.Model);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.defaults = {
        active: false
      };
      return _Class;
    })();
    SidebarView = (function() {
      __extends(_Class, Backbone.View);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.el = '#sidebar';
      _Class.prototype.events = {
        'click h2': 'toggle_content',
        'click a.assign': 'assign_sound',
        'click a.deactivate': 'deactivate_sound'
      };
      _Class.prototype.$assign_button = false;
      _Class.prototype.$deactivate_button = false;
      _Class.prototype.current_cell = false;
      _Class.prototype.initialize = function(options) {
        var $action_buttons, $assign_btn, $deactivate_btn, model, modules;
        _.bindAll(this);
        model = options.model;
        this.model = model;
        Phon.Elements.$paper.bind('cell-selected', this.select_cell);
        $action_buttons = $('<div class="buttons" />');
        $assign_btn = $('<a class="disabled assign btn">Assign</a>');
        $deactivate_btn = $('<a class="disabled deactivate btn">Deactivate</a>');
        $action_buttons.append($assign_btn);
        $action_buttons.append($deactivate_btn);
        this.$assign_btn = $assign_btn;
        this.$deactivate_btn = $deactivate_btn;
        modules = {};
        $('.module', this.el).each(function() {
          var $content, $module, module, populate, props;
          $module = $(this);
          $content = $('.content', $module);
          props = $module.attr('data-sound') ? {
            sound: new Phon.Sounds[$module.attr('data-sound')]
          } : {};
          module = new Modules[$module.attr('data-module')](props);
          $module.data('model', module);
          populate = function(elements) {
            var el, _i, _len, _results;
            _results = [];
            for (_i = 0, _len = elements.length; _i < _len; _i++) {
              el = elements[_i];
              _results.push($content.append(el));
            }
            return _results;
          };
          populate(module.gui_elements);
          if (module.get('sound')) {
            modules[$module.attr('data-sound')] = module;
          }
          module.bind('change:sound', __bind(function(module, sound) {
            $content.empty();
            populate(module.refresh_gui());
            $content.append($action_buttons);
            return module.set({
              closed: false
            });
          }, this));
          module.bind('change:closed', __bind(function(module, closed) {
            console.info('GOT CLOSED');
            if (closed) {
              return $module.removeClass('open');
            } else {
              $module.addClass('open');
              $content.append($action_buttons);
              return model.set({
                active: module
              });
            }
          }, this));
          return model.bind('change:active', function(sidebar, active) {
            var prev;
            prev = sidebar.previous('active');
            if (prev) {
              return prev.set({
                closed: true
              });
            }
          });
        });
        return this.modules = modules;
      };
      _Class.prototype.toggle_content = function(e) {
        var $module, model;
        $module = $(e.target).closest('.module');
        model = $module.data('model');
        if ($module.hasClass('persistent')) {
          return false;
        }
        return model.set({
          'closed': !(model.get('closed'))
        });
      };
      _Class.prototype.select_cell = function(e, cell) {
        var active, module, sound;
        sound = cell.sound;
        this.current_cell = cell;
        this.$assign_btn.removeClass('disabled');
        console.info('SELECT CELL', sound);
        if (sound) {
          module = this.modules[sound.type];
          this.$deactivate_btn.removeClass('disabled');
          module.set({
            sound: new Phon.Sounds[sound.type](sound)
          });
          return module.set({
            closed: false
          });
        } else {
          active = this.model.get('active');
          if (active) {
            active.set({
              closed: true
            });
          }
          return this.$deactivate_btn.addClass('disabled');
        }
      };
      _Class.prototype.assign_sound = function(e) {
        var $module, module, sound, sound_name;
        $module = $(e.target).closest('.module');
        module = this.modules[$module.attr('data-sound')];
        sound_name = $module.attr('data-sound');
        if (!this.current_cell) {
          return false;
        }
        this.$assign_btn.addClass('disabled');
        this.$deactivate_btn.addClass('disabled');
        console.info('ASSIGNING SOUND', module.get('sound').attributes);
        sound = new Phon.Sounds[sound_name](module.get('sound').attributes);
        console.info('ASSIGN_SOUND CALLED, SOUND:', sound);
        module.set({
          sound: new Phon.Sounds[sound_name],
          silent: true
        });
        module.set({
          closed: true
        });
        return sound.register(this.current_cell.row, this.current_cell.col);
      };
      _Class.prototype.deactivate_sound = function(e) {
        if (!this.current_cell) {
          return false;
        }
        this.$deactivate_btn.addClass('disabled');
        return this.current_cell.removeSound();
      };
      return _Class;
    })();
    window.Sidebar = new SidebarView({
      model: new SidebarModel
    });
    /*
    	[DAT.GUI ERROR] [object Object] either has no property 'sample', or the property is inaccessible.
    	phon.js:1111Uncaught TypeError: Cannot call method 'options' of undefined
    	*/
    $(function() {});
    MessageModel = (function() {
      __extends(_Class, Backbone.Model);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.defaults = {
        username: false,
        msg: ''
      };
      return _Class;
    })();
    MessageCollection = (function() {
      __extends(_Class, Backbone.Collection);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.model = MessageModel;
      return _Class;
    })();
    ChatModel = (function() {
      __extends(_Class, Backbone.Model);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.defaults = {
        username: false
      };
      _Class.prototype.initialize = function() {
        this.messages = new MessageCollection;
        return Phon.Socket.on('chat', __bind(function(message) {
          return this.messages.add({
            username: message.username,
            msg: message.msg
          });
        }, this));
      };
      return _Class;
    })();
    ChatView = (function() {
      __extends(_Class, Backbone.Model);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.el = '#chat';
      _Class.prototype.initialize = function(options) {
        var add_chat_content;
        _.bindAll(this);
        this.model = options.model;
        this.$scroller = $('.scroller', this.el);
        this.$content = $('.content', this.$scroller);
        this.$username = $('input.username', this.el);
        this.$input = $('input.msg', this.el);
        $(document).keyup(__bind(function(e) {
          if (e.which === 13) {
            if ($(this.el).hasClass('ready')) {
              return this.$input.focus();
            } else {
              return this.$username.focus();
            }
          }
        }, this));
        this.$input.keyup(this.send_message);
        this.$username.keyup(this.set_username);
        add_chat_content = __bind(function(content) {
          this.$content.append($("<li>" + content + "</li>"));
          return this.$scroller.scrollTop(this.$content.height());
        }, this);
        Phon.Socket.on('connect', __bind(function() {
          return add_chat_content("<strong><em>*you are now connected to phon*</em></strong>");
        }, this));
        return this.model.messages.bind('add', __bind(function(message) {
          var text, username;
          text = message.get('msg');
          username = message.get('username');
          return add_chat_content("<strong>" + username + ":</strong> " + text);
        }, this));
      };
      _Class.prototype.send_message = function(e) {
        var message, username;
        username = this.model.get('username');
        if (e.which === 13 && username) {
          message = new MessageModel({
            username: username,
            msg: this.$input.val()
          });
          Phon.Socket.emit('chat', message);
          this.$input.val('');
        }
        return e.stopPropagation();
      };
      _Class.prototype.set_username = function(e) {
        var username;
        username = this.$username.val();
        if (e.which === 13 && username) {
          this.model.set({
            username: username
          });
          $(this.el).addClass('ready');
          this.$username.blur();
          this.$input.focus();
        }
        return e.stopPropagation();
      };
      return _Class;
    })();
    return new ChatView({
      model: new ChatModel
    });
  });
  socket = null;
  Phon.Socket.on('wall', function(data) {
    var line, xys;
    switch (data.action) {
      case 'del':
        log(data.index);
        line = wallList[data.index];
        console.log(wallList);
        switch (line.info.type) {
          case "wall":
            line.info.cells.forEach(function(cell) {
              return cells["" + cell[0] + "_" + cell[1] + "_1"].walls -= cell[2];
            });
            break;
          case "split":
            cells["" + line.info.cell[0] + "_" + line.info.cell[1] + "_1"].split = 0;
        }
        line.remove();
        return wallList[data.index];
      default:
        xys = data.points;
        return vector.addWall(xys[0][0], xys[0][1], xys[1][0], xys[1][1]);
    }
  });
  server = {
    delWall: function(row1, col1, row2, col2) {
      return socket.emit('wall', {
        action: 'del',
        points: [[row1, col1], [row2, col2]]
      });
    },
    updateCell: function(row, col, instrument, settings) {
      if (instrument === null) {
        return socket.emit('cell', {
          row: row,
          col: col,
          inst: null
        });
      } else {
        return socket.emit('cell', {
          row: row,
          col: col,
          inst: instrument,
          settings: settings
        });
      }
    },
    sendEffect: function(effect, value) {
      return socket.emit('effect', {
        type: effect,
        value: value
      });
    }
  };
  doLoop = function() {
    var o;
    o = iterate();
    o.last.forEach(function(index) {
      return cells[index].occupy(false);
    });
    o["this"].forEach(function(index) {
      return cells[index].occupy(true);
    });
    return setTimeout(doLoop, Phon.Properties.tick);
  };
}).call(this);
