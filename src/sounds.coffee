Phon.Sounds = {}

#############################################
# Sound Objects (Used By Server and Audio) #
############################################

Sound = class extends Backbone.Model
	
	assign: (row, col) ->
		console.log 'registered at ', row, col

Phon.Sounds.Lead = class extends Sound
	defaults:
		type: 'Lead'
		pitch: 0
		length: 0
	
Phon.Sounds.Bass = class extends Sound
	defaults:
		type: 'Bass'
		pitch: 0
		length: 0
	
Phon.Sounds.Drum = class extends Sound
	defaults:
		type: 'Drum'
		pitch: 0
		offset: 0
		sample: 0
	
Phon.Sounds.Sample = class extends Sound
	defaults:
		type: 'Sample'
		pitch: 0
		offset: 0
		sample: 0