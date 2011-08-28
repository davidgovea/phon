Phon.Sounds = {}

#############################################
# Sound Objects (Used By Server and Audio) #
############################################

Sound = class extends Backbone.Model
	
	# this method registers the sound at a location via api
	# ckpcw: @attributes contains the data for the sound, we should notify API here
	register: (row, col) ->
		Phon.Socket.emit 'cell',
			row: row
			col: col
			sound: @attributes

Phon.Sounds.Lead = class extends Sound
	defaults:
		type: 'Lead'
		pitch: 'a'
		length: 0
	
Phon.Sounds.Bass = class extends Sound
	defaults:
		type: 'Bass'
		pitch: 'a'
		length: 0
	
Phon.Sounds.Drum = class extends Sound
	defaults:
		type: 'Drum'
		pitch: 0
		offset: 0
		sample: 'kick'
	
Phon.Sounds.Sample = class extends Sound
	defaults:
		type: 'Sample'
		pitch: 0
		offset: 0
		sample: 'snare'
