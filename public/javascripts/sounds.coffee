Phon.Sounds = {}

#############################################
# Sound Objects (Used By Server and Audio) #
############################################

Phon.Sounds.Lead = class extends Backbone.Model
	defaults:
		type: 'Lead'
		pitch: 0
		length: 0
	
Phon.Sounds.Bass = class extends Backbone.Model
	defaults:
		type: 'Bass'
		pitch: 0
		length: 0
	
Phon.Sounds.Drum = class extends Backbone.Model
	defaults:
		type: 'Drum'
		pitch: 0
		offset: 0
		sample: 0
	
Phon.Sounds.Sample = class extends Backbone.Model
	defaults:
		type: 'Sample'
		pitch: 0
		offset: 0
		sample: 0