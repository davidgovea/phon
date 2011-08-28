
#wrapper-start.coffee

window.Phon = {}
	
Phon.Properties =
	tick: 200

Phon.Elements = {}
$ ->
	Phon.Elements.$paper = $ '#paper'

Phon.Socket = io.connect(document.location.protocol + '//' + document.location.host)

# Phon.Socket.emit 'lol'

#Constants
NUM_ROWS	= 20
NUM_COLS	= 28
CELL_SIZE	= 28
cells		= {}
walls		= {}
particles	= []
occupied	= null

cell_colors	= {
	1: "#8A8A8A"
	2: "#616161"
}
particle_color	= "#52C8FF"
select_color	= "#00AEFF"

log = (msg) ->
	console.log msg
