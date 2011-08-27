
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
particle_color	= "#cc0000"
select_color	= "#0000ff"

log = (msg) ->
	console.log msg

