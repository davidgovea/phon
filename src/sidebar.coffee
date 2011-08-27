$ ->
		
	Modules = {}

	Modules.Global = class extends Backbone.Model
		
		defaults:
			closed: false
		
		initialize: ->
			@gui = new DAT.GUI
			@gui.add(Phon.Properties, 'tick').min(0).max(300)
			
	Options = {}
	
	Options.Instrument =
	
		Note: ['A', 'B', 'C', 'D', 'E', 'F', 'G']
		
		Length:
			default: 100
			min: 0
			max: 100
			
	Options.Sample =

		Sample: ['kick', 'snare']

		Pitch:
			default: 440
			min: 0
			max: 1000

		Offset:
			default: 0
			min: 0
			max: 99
	
	Modules.Instrument = class extends Backbone.Model

		defaults:
			
			closed: true
			note: Options.Instrument.Note[0]
			length: Options.Instrument.Length.default

		initialize: ->
			
			@gui = new DAT.GUI
			controller = @gui.add(@attributes, 'note')
			controller.options.apply(controller, Options.Instrument.Note)
			@gui.add(@attributes, 'length').min(Options.Instrument.Length.min).max(Options.Instrument.Length.max)
			
	Modules.Sample = class extends Backbone.Model

		defaults:
			
			closed: true
			sample: Options.Sample.Sample[0]
			pitch: Options.Sample.Pitch.default
			offset: Options.Sample.Offset.default

		initialize: ->
			
			@gui = new DAT.GUI
			controller = @gui.add(@attributes, 'sample')
			controller.options.apply(controller, Options.Sample.Sample)
			@gui.add(@attributes, 'pitch').min(Options.Sample.Pitch.min).max(Options.Sample.Pitch.max)
			@gui.add(@attributes, 'offset').min(Options.Sample.Offset.min).max(Options.Sample.Offset.max)
			
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
				$module.data 'model', module
				$('.content', $module).append module.gui.domElement
				
				module.bind 'change:closed', (module, closed) ->
					$module[if !closed then 'addClass' else 'removeClass']('open')
				
		
		toggle_content: (e) ->
			
			$module = $(e.target).closest('.module')
			model = $module.data('model')
			active = @model.get 'active'
			
			if $module.hasClass('persistent')
				return false
				
			model.set 'closed': !(model.get 'closed')
			
			if active
				active.set closed: true
				
			@model.set active: model
		
	new SidebarView
	 	model: new Sidebar