
#wrapper-end.coffee

devList = []
doLoop = ->
	devList.forEach((cell) ->
		raphGrid[cell].shape.attr("fill", "#ccc")
	)
	devList = []

	o = iterate()

	for ind,cell of o.h
		#log cell
		raphGrid["#{cell.row}_#{cell.col}_#{cell.state}"].shape.attr('fill', '#0f0')
		devList.push("#{cell.row}_#{cell.col}_#{cell.state}")
	
	setTimeout doLoop, 500



#####TESTING#####TESTING#####

window.doLoop = doLoop
window.particles = particles
window.cells = cells
setTimeout(->
	paper = Raphael("paper", 800, 800)
	window.raphGrid = paper.octogrid(10,10,10,10,32,'#d1d1d1', '#d1d1d1');
	init()
	particles.push(
		new Particle(3,2,1,1), 
		new Particle(5,4,1,8), 
		new Particle(3,6,1,4),
		new Particle(9,10,1,4),
		new Particle(6,6,1,8),
		new Particle(7,2,1,1),
		new Particle(4,5,1,2)
	)
	doLoop()

, 2000)