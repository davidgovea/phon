#Constants
NUM_ROWS	= 10
NUM_COLS	= 10
cells		= {}
particles	= []

class Particle
	constructor: (@row, @col, @state, @direction, lifetime) ->
		@lifetime = lifetime ? 16
	move: ->
		#move it!
	reverse: ->
		#CHANGE COURSE CAPTAIN
	checkObstacles: ->
		#Shit in da way?

class Cell
	constructor: (@row, @col, @state) ->


init = ->
	for row in [1..NUM_ROWS]
		for col in [1..NUM_COLS]
			cells["#{row}_{col}_1"] = new Cell row, col, 1
			unless row is NUM_ROWS or col is NUM_COLS
				cells["#{row}_#{col}_2"] = new Cell row, col, 2
