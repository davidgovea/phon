
#wrapper-start.coffee

#Constants
NUM_ROWS	= 10
NUM_COLS	= 10
cells		= {}
particles	= []
occupied	= null

cell_colors	= {
	1: "#d1d1d1"
	2: "#00bb00"
}
particle_color = "#cc0000"

log = (msg) ->
	console.log msg

