

express	= require 'express'
nko		= require('nko')('Z6+o2A6kn7+tCofT')
coffee	= require 'coffee-script'
app		= module.exports = express.createServer()
io		= require('socket.io').listen app
#state	= require './statemachine'


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
 	main: "main state"
 	default: "default state"
}


## socket.IO ##

io.sockets.on 'connection', (socket) ->

	socket.emit 'connection'

	socket.on 'room', (id, callback) ->
		if id is ""	then id = "main"
		console.log "got client in room: "+id
		if states[id]?
			state = states[id]
		else
			state = 'empty!' #TODO - handle
		socket.join(id)
		socket.set('roomId', id, ->
			socket.emit 'init', state
		)


	socket.on 'cell', (cell_properties) ->
		socket.get('roomId', (err, id) ->
			io.sockets.in(id).emit 'cell', cell_properties
		)
	
	socket.on 'wall', (data) ->
		socket.get('roomId', (err, id) ->
			io.sockets.in(id).emit 'wall', data
		)
	
	socket.on 'chat', (msg) ->
		socket.get('roomId', (err, id) ->
			io.sockets.in(id).emit 'chat', msg
		)

	socket.on 'effect', (parameters) ->
		socket.get('roomId', (err, id) ->
			io.sockets.in(id).emit 'effect', parameters
		)
		

app.listen (parseInt(process.env.PORT) || 3000)
console.log "Listening on #{app.address().port}"
