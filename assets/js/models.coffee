NUM_ROWS	= 10
NUM_COLS	= 10
TARGET_ID	= 'grid'

## Binary states: particle directions
N	= 512
S	= 8
E	= 1
W	= 64
NE	= 1024
SE	= 2
SW	= 16
NW	= 128


class BaseCell extends Backbone.Model
	defaults:
		row: 0
		col: 0


class Cell extends BaseCell
	defaults:
		note: null
		split: false
		state: 0
	initialize: ->
		#draw octogon at location
		@bind "change:split", ->
			console.log "i'm split!"
		@bind "change:state", ->
			#update icon
		@view = new CellView model: @
		

class Diamond extends BaseCell
	defaults:
		state: 1
	initialize: ->
		@view = new DiamondView model: @



class Particle extends Backbone.Model
	defaults:
		lifetime: 32
		excited: false
		row: 0
		col: 0
		dir: 0
	move: ->
		dir = @get 'dir'
		if not excited
			if 		dir & E then @set col: @get('col')+1
			else if	dir & S then @set row: @get('row')+1
			else if	dir & W then @set col: @get('col')-1
			else if	dir & N then @set row: @get('row')-1
			else 				# High energy particle in normal space
				if 		dir & SE then
				else if	dir & SW then @set col: @get('col')-1
				else if	dir & NW
					@set {row: @get('row')-1}, silent: true
					@set col: @get('col')-1
				else if	dir & NE then @set row: @get('row')-1
				@set excited: true
		else
			if 		dir & SE
				@set {row: @get('row')+1}, silent: true
				@set col: @get('col')+1
			else if	dir & SW then @set row: @get('row')+1
			else if	dir & NW then
			else if	dir & NE then @set col: @get('col')+1
			@set excited: false
		if @get('lifetime') > 0 then @set lifetime: @get('lifetime')-1
	reverse: ->
		dir = @get 'dir'
		if		dir & N then dir	= S
		else if	dir & S then dir	= N
		else if	dir & E then dir	= W
		else if	dir & W then dir	= E
		else if	dir & SE then dir	= NW
		else if dir & SW then dir	= NE
		else if dir & NW then dir	= SE
		else if dir & NE then dir	= SW
		@set dir: dir



class Emitter extends Backbone.Model
	defaults:
		index:	0
		period:	16
		row:	0
		col:	0
		dir:	1
	initialize: ->
		#set direction, based on Row/Col
	step: ->
		if ++@index is @period
			@index = 0
			@emit
	emit: ->
		#add particle to grid


class Emitters extends Backbone.Collection
	model: Emitter
	initialize: ->
	

class Grid extends Backbone.Collection
	# model: Cell
	initialize: ->





## VIEWS ##
class CellGroup extends Backbone.View
	tagName: "div"
	className: "cellGroup"

class CellView extends Backbone.View
	tagName: "div"
	className: "oct"
	
	events:
		"click": "onClick"
	initialize: ->
		#@model.bind 'someevent', @somefunc
	onClick: ->
		move(@el).set('z-index', 1000).scale(3).set('opacity', 0).end(->
			move(@el).scale(1).set('z-index', 0).duration(0).end(->
				move(@el).set('opacity', 100).end()
			)
		)
		console.log "clicked row #{@model.get 'row'}, col #{@model.get 'col'}"

class DiamondView extends Backbone.View
	tagName: "div"
	className: "dia"
	
	events:
		"click": "onClick"
	initialize: ->
		# $(@el).css 'left', @model.get('col')*45+"px"
		# $(@el).css 'top', @model.get('row')*45+"px"
	onClick: ->
		console.log "Diamond! #{@model.get 'row'}, col #{@model.get 'col'}"


class Phon extends Backbone.Model
	defaults:
		rows: NUM_ROWS
		cols: NUM_COLS
	initialize: ->
		target = $("##{TARGET_ID}")

		@grid = new Grid()

		for row in [1..NUM_ROWS]
			for col in [1..NUM_COLS]
				group = new CellGroup().render().el
				console.log group
				$(group).append @addCell row, col
				unless row is 1 or col is NUM_COLS
					$(group).append @addDiamond (row-1), (col-1)

				target.append group
			target.append '<br/>'
		# for row in [1...NUM_ROWS]
		# 	for col in [1...NUM_COLS]
		# 		target.append @addDiamond row, col
	addCell: (row, col) ->
		cell = new Cell row: row, col: col
		@grid.add cell
		return cell.view.render().el
	addDiamond: (row, col) ->
		dia = new Diamond row: row, col: col
		@grid.add dia
		return dia.view.render().el



		

$ ->
	alert 'time'
	window.Phon = new Phon()