beatLength = 200


express	= require 'express'
coffee	= require 'coffee-script'
app		= module.exports = express.createServer()
io		= require('socket.io').listen app
state	= require './statemachine'


app.configure ->
	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'jade'
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use app.router
	app.use express.compiler(src: __dirname + '/src', dest: __dirname + '/public/javascripts' , enable: ['coffeescript'])
	app.use express.static __dirname + '/public' 
app.configure 'development', ->
	app.use express.errorHandler dumpExceptions: true, showStack: true
app.configure 'production', ->
	app.use express.errorHandler()


## Routes ##

app.get '/:id?', (req, res) ->
	res.render 'index',
		title: 'Phon'


## State ##

states = {
 	main:
 		cells: state.init()
 		walls: {}
 		emitters: state.emitters()
 		effects:
 			'reverb': 0
 			'bitcrusher': 0
}

console.log states.main.cells
getActiveCells = (stateid) ->
	active = []
	state = states[stateid]
	for index, cell of state.cells
		if cell.active
			active.push index: index, sound: cell.sound
	
	console.log "--------------------"
	console.log active
	return active

getWallIndex = (row1, col1, row2, col2) ->
	rowdiff		= row1-row2
	coldiff		= col1-col2
	if col1 >= col2
		upperCol = col1
		order	= [row1, col1, row2, col2]
	else
		upperCol = col2
		order = [row2, col2, row1, col1]
	if row1 >= row2 
		upperRow = row1
		if row1 isnt row2 then order = [row1, col1, row2, col2]
	else
		upperRow = row2
		order = [row2, col2, row1, col1]
	return "#{order[0]}_#{order[1]}_#{order[2]}_#{order[3]}"

getWalls = (stateid) ->
	walls = []
	state = states[stateid]
	for index, wall of state.walls
		if wall then walls.push index
	return walls

iterateEmitters = ->
	for name, state in states
		for key, emitter in state.emitters
			emitter.index = (emitter.index + 1) % emitter.life
	setTimeout iterateEmitters, beatLength


## socket.IO ##

io.sockets.on 'connection', (socket) ->

	socket.once 'connect'

	socket.on 'room', (id, callback) ->
		if id is ""	then id = "main"
		console.log "got client in room: "+id
		if states[id]?
			state = states[id]
		else
			walls = {}
			state = {
				cells: state.init()
				walls: walls
		 		emitters: state.emitters()
				effects:
					'reverb': 0
					'bitcrusher': 0
			} 
			states[id] = state
			console.log state.cells
		socket.join(id)
		socket.set('roomId', id, ->
			socket.emit 'init', cells: getActiveCells(id), walls: getWalls(id), emitters: state.emitters, effects: state.effects
		)
	
	socket.on 'effect', (params) ->
		console.log params
		socket.get('roomId', (err, id) ->
			state = states[id]
			state.effects[params.type] += params.amount
			io.sockets.in(id).emit 'effect', params
		)

	socket.on 'cell', (cell_properties) ->
		console.log cell_properties
		socket.get('roomId', (err, id) ->
			io.sockets.in(id).emit 'cell', cell_properties
			index = "#{cell_properties.row}_#{cell_properties.col}_1"
			cell = states[id].cells[index]
			if cell_properties.sound isnt null
				cell?.active = true
				cell?.sound = cell_properties.sound
			else
				cell?.active = false

			
		)
	
	socket.on 'wall', (data) ->
		socket.get('roomId', (err, id) ->
			switch data.action
				when 'del'
					states[id].walls[data.index] = null
				when 'split', 'add'
					pts = data.points
					states[id].walls[getWallIndex pts[0][0], pts[0][1], pts[1][0], pts[1][1]] = true
			io.sockets.in(id).emit 'wall', data
		)
	
	socket.on 'chat', (msg) ->
		socket.get('roomId', (err, id) ->
			io.sockets.in(id).emit 'chat', msg
		)
		

app.listen (parseInt(process.env.PORT) || 3000)
console.log "Listening on #{app.address().port}"
