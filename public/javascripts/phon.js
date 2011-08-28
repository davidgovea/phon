(function() {
  var Cell, NUM_COLS, NUM_ROWS, Particle, StateHash, cell_colors, cells, collide, decays, doLoop, init, iterate, log, occupied, particle_color, particles, select_color;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  window.Phon = {};
  Phon.Properties = {
    tick: 200
  };
  NUM_ROWS = 10;
  NUM_COLS = 10;
  cells = {};
  particles = [];
  occupied = null;
  cell_colors = {
    1: "#d1d1d1",
    2: "#00bb00"
  };
  particle_color = "#cc0000";
  select_color = "#0000ff";
  log = function(msg) {
    return console.log(msg);
  };
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
        log(cells["" + this.row + "_" + this.col + "_1"]);
        return cells["" + this.row + "_" + this.col + "_1"].select();
      };
      Oct.prototype.onDblClick = function(evt) {
        return log("dblclick " + this.row + "," + this.col);
      };
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
          pathString = "M" + (this.shape.attrs.x + this.shape.attrs.height / 2) + " " + (this.shape.attrs.y + this.shape.attrs.height / 2) + "l" + (line[0] * width) + " " + (line[1] * width);
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
        if (this.dragLine != null) {
          log(this.dragLine.valid);
          if (!this.dragLine.valid) {
            this.dragLine.remove();
          } else {

          }
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
          diamond = new Diamond(x, y, side, row, col);
          diamond.shape.attr('fill', cell_colors[2]);
          cells["" + row + "_" + col + "_2"].shape = diamond.shape;
        }
        x += width;
      }
      y += width;
    }
    return console.timeEnd('octogrid');
  };
  Particle = (function() {
    function Particle(row, col, state, direction, lifetime) {
      this.row = row;
      this.col = col;
      this.state = state;
      this.direction = direction;
      this.lifetime = lifetime != null ? lifetime : 200;
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
    Particle.prototype.checkObstacles = function() {
      if (!this.excited) {
        if ((this.row === 1 && this.direction === 8) || (this.row === NUM_ROWS && this.direction === 2) || (this.col === 1 && this.direction === 4) || (this.col === NUM_COLS && this.direction === 1)) {
          return this.reverse();
        }
      } else if (this.state === 1) {
        if ((this.row === 1 && (this.direction === 16 || this.direction === 64)) || (this.row === NUM_ROWS && (this.direction === 1 || this.direction === 4)) || (this.col === 1 && (this.direction === 4 || this.direction === 16)) || (this.col === NUM_COLS && (this.direction === 1 || this.direction === 64))) {
          return this.reverse();
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
    Cell.prototype.activate = function() {};
    Cell.prototype.deactivate = function() {};
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
          'stroke-width': 3
        });
        return cells.selected = this;
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
    Cell.prototype.occupy = function(state) {
      if (state === true) {
        return this.shape.attr({
          fill: particle_color
        });
      } else {
        return this.shape.attr({
          fill: cell_colors[this.state]
        });
      }
    };
    return Cell;
  })();
  StateHash = (function() {
    function StateHash() {
      this.h = {};
      this.lastBeat = [];
      this.thisBeat = [];
    }
    StateHash.prototype.add = function(particle) {
      var index;
      index = "" + particle.row + "_" + particle.col + "_" + particle.state;
      if (!this.h[index]) {
        this.h[index] = cells[index];
        this.h[index].particles = [];
        this.h[index].sums = [0, 0];
        this.thisBeat.push(index);
      }
      this.h[index].sums[particle.excited] += particle.direction;
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
    }
  };
  init = function() {
    var col, row, _results;
    occupied = new StateHash;
    _results = [];
    for (row = 1; 1 <= NUM_ROWS ? row <= NUM_ROWS : row >= NUM_ROWS; 1 <= NUM_ROWS ? row++ : row--) {
      _results.push((function() {
        var _results2;
        _results2 = [];
        for (col = 1; 1 <= NUM_COLS ? col <= NUM_COLS : col >= NUM_COLS; 1 <= NUM_COLS ? col++ : col--) {
          cells["" + row + "_" + col + "_1"] = new Cell(row, col, 1);
          _results2.push(!(row === NUM_ROWS || col === NUM_COLS) ? cells["" + row + "_" + col + "_2"] = new Cell(row, col, 2) : void 0);
        }
        return _results2;
      })());
    }
    return _results;
  };
  iterate = function() {
    var cell, cellIndex, particle, toKill, _i, _len, _ref;
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
    _ref = occupied.h;
    for (cellIndex in _ref) {
      cell = _ref[cellIndex];
      if (cell.state === 1) {
        if (cell.split) {} else {
          if (cell.sums[1] || cell.particles.length > 1) {
            collide(cell.sums, cell.particles);
          }
          cell.particles.forEach(function(p) {
            return p.checkObstacles();
          });
        }
        if (cell.active) {
          log("TODO / record note playback info");
        }
      } else {

      }
    }
    return {
      "this": occupied.thisBeat,
      last: occupied.lastBeat
    };
  };
  collide = function(sums, particles) {
    var dir, dirs, eSum, nSum, result;
    nSum = sums[0];
    eSum = sums[1];
    switch (nSum) {
      case 1:
      case 4:
      case 8:
      case 16:
        switch (eSum) {
          case 1:
          case 4:
          case 16:
          case 64:
            break;
          case 2:
          case 8:
          case 32:
          case 128:
        }
        break;
      case 5:
      case 10:
        switch (eSum) {
          case 0:
            return particles.forEach(function(p) {
              return p.reverse();
            });
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
            return particles.forEach(function(p) {
              p.excite();
              return p.direction = dir;
            });
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
            return particles.forEach(function(p) {
              p.excite();
              if (p.direction === result.kill) {
                return p.kill();
              } else {
                return p.direction = result.dir[p.direction];
              }
            });
        }
        break;
      case 15:
        switch (eSum) {
          case 0:
            dirs = [1, 4, 16, 64].shuffle();
            return particles.forEach(function(p) {
              p.econsoxcite();
              return p.direction = dirs.shift();
            });
        }
        break;
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
              return particles.forEach(function(p) {
                p.decay();
                return p.direction = dirs.shift();
              });
            }
            break;
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
              return particles.forEach(function(p) {
                p.decay();
                return p.direction = dirs.shift();
              });
            }
            break;
          case 17:
          case 64:
            return dirs = [[2, 8], [1, 4]].shuffle().shift().shuffle();
        }
    }
  };
  $(function() {
    var Modules, Sidebar, SidebarView;
    Modules = {};
    Modules.Global = (function() {
      __extends(_Class, Backbone.Model);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.defaults = {
        closed: false
      };
      _Class.prototype.initialize = function() {
        this.gui = new DAT.GUI;
        return this.gui.add(Phon.Properties, 'tick').min(0).max(300);
      };
      return _Class;
    })();
    Modules.Instrument = (function() {
      __extends(_Class, Backbone.Model);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.defaults = {
        closed: true,
        note: 'a',
        length: 25
      };
      _Class.prototype.initialize = function() {
        this.gui = new DAT.GUI;
        this.gui.add(this.attributes, 'length').min(0).max(100);
        return this.gui.add(this.attributes, 'note').options({
          'a': 220,
          'a#': 233.08,
          'b': 246.94,
          'c': 261.63,
          'c#': 277.18,
          'd': 293.66,
          'd#': 311.13,
          'e': 329.63,
          'f': 349.23,
          'f#': 369.99,
          'g': 392.00
        });
      };
      return _Class;
    })();
    Modules.Sample = (function() {
      __extends(_Class, Backbone.Model);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.defaults = {
        closed: true,
        sample: 'kick',
        pitch: 440,
        offset: 0
      };
      _Class.prototype.initialize = function() {
        this.gui = new DAT.GUI;
        this.gui.add(this.attributes, 'sample').options('kick', 'snare');
        this.gui.add(this.attributes, 'pitch').min(0).max(440);
        return this.gui.add(this.attributes, 'offset').min(0).max(100);
      };
      return _Class;
    })();
    Sidebar = (function() {
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
        'click h2': 'toggle_content'
      };
      _Class.prototype.initialize = function(options) {
        var model;
        _.bindAll(this);
        model = options.model;
        return $('.module', this.el).each(function() {
          var $module, module;
          $module = $(this);
          module = new Modules[$module.attr('data-module')];
          $module.data('model', module);
          $('.content', $module).append(module.gui.domElement);
          module.bind('change:closed', __bind(function(module, closed) {
            $module[closed ? 'removeClass' : 'addClass']('open');
            if (!closed) {
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
      return _Class;
    })();
    return new SidebarView({
      model: new Sidebar
    });
  });
  doLoop = function() {
    var o;
    o = iterate();
    o.last.forEach(function(index) {
      return cells[index].occupy(false);
    });
    o["this"].forEach(function(index) {
      return cells[index].occupy(true);
    });
    setTimeout(doLoop, Phon.Properties.tick);
    return console.timeEnd('loop');
  };
  window.doLoop = doLoop;
  window.particles = particles;
  window.cells = cells;
  setTimeout(function() {
    var paper;
    init();
    paper = Raphael("paper", 1200, 800);
    paper.octogrid(1, 1, NUM_ROWS, NUM_COLS, 32);
    particles.push(new Particle(3, 2, 1, 1), new Particle(5, 4, 1, 8), new Particle(3, 6, 1, 4), new Particle(9, 10, 1, 4), new Particle(6, 6, 1, 8), new Particle(7, 2, 1, 1), new Particle(4, 5, 1, 2));
    return doLoop();
  }, 2000);
}).call(this);