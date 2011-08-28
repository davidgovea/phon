
#wrapper-start.coffee

window.Phon = {}
	
Phon.Properties =
	tick: 200
	roomId: document.location.pathname.substring(1)

Phon.Elements = {}
$ ->
	Phon.Elements.$paper = $ '#paper'

Phon.Socket = io.connect(document.location.protocol + '//' + document.location.host)
Phon.Socket.on('connection', ->
	Phon.Socket.emit "room", Phon.Properties.roomId
)
Phon.Socket.on('init', (data) ->
	console.log 'init'
	console.log data

)

# Phon.Socket.emit 'lol'

#Constants
NUM_ROWS	= 18
NUM_COLS	= 24
CELL_SIZE	= 28
cells		= {}
wallList	= {}
particles	= []
occupied	= null

cell_colors	= {
	1: "#8A8A8A"
	2: "#616161"
}
particle_color	= "#52C8FF"
select_color	= "#00AEFF"
wall_color		= '#1ED233'

log = (msg) ->
	console.log msg
