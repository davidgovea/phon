Phon.Sounds = {}

#############################################
# Sound Objects (Used By Server and Audio) #
############################################

Sound = class extends Backbone.Model
	
	# this method registers the sound at a location via api
	register: (row, col) ->
		# ckpcw: @attributes contains the data from 
		console.log 'registering', @attributes, 'at', row, col

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