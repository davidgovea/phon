
#wrapper-end.coffee

doLoop = ->
	o = iterate()

	o.last.forEach((index)->
		cells[index].occupy false
	)
	o.this.forEach((index)->
		cells[index].occupy true
	)
	setTimeout doLoop, Phon.Properties.tick

