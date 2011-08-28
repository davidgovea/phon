

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

app.get '/', (req, res) ->
	res.render 'index',
		title: 'Phon'


## State ##

# states: {
# 	main:
# 	default:
# }


## socket.IO ##

io.sockets.on 'connection', (socket) ->

	socket.on 'init', (id) ->
		if id is ""		#index
			console.log "got init"
		else
			#get or create state map


	socket.on 'cell', (cell_properties) ->
		io.sockets.emit 'cell', cell_properties
	
	socket.on 'wall', (data) ->
		io.sockets.emit 'wall', data
	
	socket.on 'chat', (msg) ->
		io.sockets.emit 'chat', msg

app.listen (parseInt(process.env.PORT) || 3000)
console.log "Listening on #{app.address().port}"
