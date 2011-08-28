

express	= require 'express'
nko		= require('nko')('Z6+o2A6kn7+tCofT')
coffee	= require 'coffee-script'
app		= module.exports = express.createServer()


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

app.listen (parseInt(process.env.PORT) || 3000)
console.log "Listening on #{app.address().port}"
