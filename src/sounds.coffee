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

Instrument = class extends Sound
	defaults:
		pitch: 0
		length: 0

Sample = class extends Sound
	defaults:
		pitch: 0
		offset: 0
		sample: 0

Phon.Sounds.Lead = class extends Instrument
	defaults: _.extend(Instrument.prototype.defaults, type: 'Lead')
	
Phon.Sounds.Bass = class extends Instrument
	defaults: _.extend(Instrument.prototype.defaults, type: 'Bass')
	
Phon.Sounds.Drum = class extends Sample
	defaults: _.extend(Sample.prototype.defaults, type: 'Drum')
	
Phon.Sounds.Sample = class extends Sample
	defaults: _.extend(Sample.prototype.defaults, type: 'Sample')