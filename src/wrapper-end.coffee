
#wrapper-end.coffee

doLoop = ->
	#console.time 'loop'

	o = iterate()

	o.last.forEach((index)->
		cells[index].occupy false
	)
	o.this.forEach((index)->
		cells[index].occupy true
	)
	setTimeout doLoop, Phon.Properties.tick
	console.timeEnd 'loop'



#####TESTING#####TESTING#####

window.doLoop = doLoop
window.particles = particles
window.cells = cells
setTimeout(->

	
	# particles.push(
	# 	new Particle(3,2,1,1), 
	# 	new Particle(5,4,1,8), 
	# 	new Particle(3,6,1,4),
	# 	new Particle(9,10,1,4),
	# 	new Particle(6,6,1,8),
	# 	new Particle(7,2,1,1),
	# 	new Particle(4,5,1,2)
	# )
	doLoop()

, 2000)