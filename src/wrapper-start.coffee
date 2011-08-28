
#wrapper-start.coffee

window.Phon = {}
window.Phon.enabled = AudioContext? or webkitAudioContext? or (new Audio()).mozSetup?

$ ->
	if (window.Phon.enabled)
		$('#disclaimer').fadeIn()
	else
		$('#disclaimer').remove()

if window.Phon.enabled
	return false
	
Phon.Properties =
	tick: 200
	roomId: document.location.pathname.substring(1)

Phon.Elements = {}
$ ->
	Phon.Elements.$paper = $ '#paper'

Phon.Socket = io.connect(document.location.protocol + '//' + document.location.host)
Phon.Socket.on 'connect', ->
	if paper is null
		init()
		vector.init()
	
	Phon.Socket.emit "room", Phon.Properties.roomId

Phon.Socket.on 'init', (data) ->
	console.log data
	walls = data.walls
	for wallIndex in walls
		rc = wallIndex.split("_")
		vector.addWall rc[0], rc[1], rc[2], rc[3]
	
	for key, emit in data.emitters
		emitterHash[key].setIndex emitter.index

	for cell in data.cells
		cells[cell.index].active = true
		cells[cell.index].sound	= cell.sound

	doLoop()
	



Phon.Socket.on 'cell', (cell_properties) ->
	console.log cell_properties
	cell = cells["#{cell_properties.row}_#{cell_properties.col}_1"]
	cell.setActive true
	cell.addSound cell_properties.sound


#Constants
NUM_ROWS	= 18
NUM_COLS	= 24
CELL_SIZE	= 28
cells		= {}
wallList	= {}
particles	= []
occupied	= null
paper = null

cell_colors	= {
	1: "#8A8A8A"
	2: "#616161"
}
particle_color	= "#52C8FF"
select_color	= "#00AEFF"
wall_color		= '#1ED233'

note_color		= "#E61D5F"

log = (msg) ->
	console.log msg
