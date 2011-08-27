(function() {
  var Cell, NUM_COLS, NUM_ROWS, Particle, StateHash, cells, collide, decays, devList, doLoop, init, iterate, log, particles;
  NUM_ROWS = 10;
  NUM_COLS = 10;
  cells = {};
  particles = [];
  log = function(msg) {
    return console.log(msg);
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
    return Cell;
  })();
  StateHash = (function() {
    function StateHash() {
      this.h = {};
    }
    StateHash.prototype.add = function(particle) {
      var index;
      index = "" + particle.row + "_" + particle.col + "_" + particle.state;
      if (!this.h[index]) {
        this.h[index] = cells[index];
        this.h[index].particles = [];
        this.h[index].sums = [0, 0];
      }
      this.h[index].sums[particle.excited] += particle.direction;
      return this.h[index].particles.push(particle);
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
    var cell, cellIndex, index, occupied, particle, toKill, _len, _ref;
    occupied = new StateHash;
    toKill = [];
    for (index = 0, _len = particles.length; index < _len; index++) {
      particle = particles[index];
      if (particle.lifetime === 0) {
        toKill.push(index);
      } else {
        particle.move();
        occupied.add(particle);
      }
    }
    _ref = occupied.h;
    for (cellIndex in _ref) {
      cell = _ref[cellIndex];
      if (cell.state === 1) {
        if (cell.split) {} else {
          if (cell.sums[1] || cell.particles.length > 1) {
            log(cell.sums);
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
        log("I'm a diamond!");
      }
    }
    return occupied;
  };
  collide = function(sums, particles) {
    var dir, dirs, eSum, nSum, result;
    nSum = sums[0];
    eSum = sums[1];
    switch (nSum) {
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
              log(p);
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
              p.excite();
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
              log(eSum);
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
  devList = [];
  doLoop = function() {
    var cell, ind, o, _ref;
    devList.forEach(function(cell) {
      return raphGrid[cell].attr("fill", "#ccc");
    });
    devList = [];
    o = iterate();
    _ref = o.h;
    for (ind in _ref) {
      cell = _ref[ind];
      raphGrid["" + cell.row + "_" + cell.col + "_" + cell.state].attr('fill', '#0f0');
      devList.push("" + cell.row + "_" + cell.col + "_" + cell.state);
    }
    return setTimeout(doLoop, 500);
  };
  window.doLoop = doLoop;
  window.particles = particles;
  window.cells = cells;
  setTimeout(function() {
    var paper;
    paper = Raphael("paper", 800, 800);
    window.raphGrid = paper.octogrid(10, 10, 10, 10, 32, '#d1d1d1');
    init();
    particles.push(new Particle(3, 2, 1, 1), new Particle(5, 4, 1, 8), new Particle(3, 6, 1, 4), new Particle(9, 10, 1, 4), new Particle(6, 6, 1, 8), new Particle(7, 2, 1, 1), new Particle(4, 5, 1, 2));
    return doLoop();
  }, 2000);
}).call(this);
