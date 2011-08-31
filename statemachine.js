(function() {
  (function(exports) {
    var Cell, Emitter, NUM_COLS, NUM_ROWS, Particle, StateHash, cells;
    NUM_ROWS = 18;
    NUM_COLS = 24;
    cells = {};
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
      Particle.prototype.checkObstacles = function(repeat) {
        if (repeat == null) {
          repeat = false;
        }
        if (!this.excited) {
          if ((this.row === 1 && this.direction === 8) || (this.row === NUM_ROWS && this.direction === 2) || (this.col === 1 && this.direction === 4) || (this.col === NUM_COLS && this.direction === 1)) {
            if (!repeat) {
              return this.reverse();
            } else {
              return this.lifetime = 0;
            }
          } else if (cells["" + this.row + "_" + this.col + "_1"].walls & this.direction) {
            if (!repeat) {
              return this.reverse();
            } else {
              return this.lifetime = 0;
            }
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
      Cell.prototype.sound = false;
      Cell.prototype.addSound = function(sound) {
        return this.sound = sound;
      };
      Cell.prototype.removeSound = function() {
        return this.sound = false;
      };
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
      return Cell;
    })();
    Emitter = (function() {
      function Emitter() {}
      return Emitter;
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
    exports.init = function() {
      var col, row;
      cells = {};
      for (row = 1; 1 <= NUM_ROWS ? row <= NUM_ROWS : row >= NUM_ROWS; 1 <= NUM_ROWS ? row++ : row--) {
        for (col = 1; 1 <= NUM_COLS ? col <= NUM_COLS : col >= NUM_COLS; 1 <= NUM_COLS ? col++ : col--) {
          cells["" + row + "_" + col + "_1"] = new Cell(row, col, 1);
        }
      }
      return cells;
    };
    return exports.emitters = function() {
      var cell, emitList, emitters, _i, _len;
      emitters = [
        {
          name: "1_7",
          life: 8,
          index: 0,
          active: true
        }, {
          name: "1_14",
          life: 16,
          index: 0,
          active: true
        }, {
          name: "1_21",
          life: 32,
          index: 0,
          active: true
        }, {
          name: "5_24",
          life: 16,
          index: 0,
          active: true
        }, {
          name: "8_1",
          life: 8,
          index: 0,
          active: true
        }, {
          name: "12_24",
          life: 16,
          index: 0,
          active: true
        }, {
          name: "15_1",
          life: 32,
          index: 0,
          active: true
        }, {
          name: "18_4",
          life: 16,
          index: 0,
          active: true
        }, {
          name: "18_11",
          life: 8,
          index: 0,
          active: true
        }, {
          name: "18_18",
          life: 16,
          index: 0,
          active: true
        }
      ];
      emitList = {};
      for (_i = 0, _len = emitters.length; _i < _len; _i++) {
        cell = emitters[_i];
        emitList[cell.name] = {
          life: cell.life,
          index: cell.index,
          active: true
        };
      }
      return emitList;
    };
  })(exports);
}).call(this);
