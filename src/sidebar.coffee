$ ->
	
	Defaults = {}
	
	Defaults.Instrument =
		
		Note:
			'a': 220
			'a#': 233.08
			'b': 246.94
			'c': 261.63
			'c#': 277.18
			'd': 293.66
			'd#': 311.13
			'e': 329.63
			'f': 349.23
			'f#': 369.99
			'g': 392.00
		
		Length:
			default: 100
			min: 0
			max: 100
			
	Defaults.Sample =

		Sample: ['kick', 'snare']

		Pitch:
			default: 440
			min: 0
			max: 1000

		Offset:
			default: 0
			min: 0
			max: 99
		
	Modules = {}

	Modules.Global = class extends Backbone.Model
		
		defaults:
			closed: false
		
		initialize: ->
			@gui = new DAT.GUI
			@gui.add(Phon.Properties, 'tick').min(0).max(300)
	
	Modules.Instrument = class extends Backbone.Model

		defaults:
			
			closed: true
			note: Defaults.Instrument.Note['a']
			length: Defaults.Instrument.Length.default

		initialize: ->
			
			@gui = new DAT.GUI
			@gui.add(@attributes, 'note').options(Defaults.Instrument.Note)
			@gui.add(@attributes, 'length').min(Defaults.Instrument.Length.min).max(Defaults.Instrument.Length.max)
			
	Modules.Sample = class extends Backbone.Model

		defaults:
			
			closed: true
			sample: Defaults.Sample.Sample[0]
			pitch: Defaults.Sample.Pitch.default
			offset: Defaults.Sample.Offset.default

		initialize: ->
			
			@gui = new DAT.GUI
			controller = @gui.add(@attributes, 'sample')
			controller.options.apply(controller, Defaults.Sample.Sample)
			@gui.add(@attributes, 'pitch').min(Defaults.Sample.Pitch.min).max(Defaults.Sample.Pitch.max)
			@gui.add(@attributes, 'offset').min(Defaults.Sample.Offset.min).max(Defaults.Sample.Offset.max)
			
	Sidebar = class extends Backbone.Model

		defaults:
			active: false
			
	SidebarView = class extends Backbone.View
	
		el: '#sidebar'
	
		events:
			'click h2': 'toggle_content'
			
		initialize: ->
			
			_.bindAll this
			
			$('.module', @el).each ->
				
				$module = $(this)
				module = new Modules[$module.attr 'data-module']
				
				# store reference to the model in DOM to be easily accessed from events
				$module.data 'model', module
				
				# move DAT.GUI into container
				$('.content', $module).append module.gui.domElement
				
				# show/hide the panels when the module's "closed" property changes
				module.bind 'change:closed', (module, closed) ->
					$module[if !closed then 'addClass' else 'removeClass']('open')
				
		# shows / hides the current sidebar module
		toggle_content: (e) ->
			
			$module = $(e.target).closest('.module')
			model = $module.data('model')
			active = @model.get 'active'
			
			# module can have a "persistent" class to refuse closing
			if $module.hasClass('persistent')
				return false
			
			# set property/display on new module
			model.set 'closed': !(model.get 'closed')
			
			# set property/display on previous module
			if active && active != model
				active.set closed: true
				
			# update "current" module
			@model.set active: model
	
	# init sidebar
	new SidebarView
	 	model: new Sidebar