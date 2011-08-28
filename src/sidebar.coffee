$ ->
		
	Modules = {}
	
	#############################
	# Instrument Sidebar Module #
	#############################
	
	Modules.Instrument = class extends Backbone.Model

		defaults:
			type: ''
			closed: true
			note: 'a'
			length: 25

		initialize: ->
			notes =
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
			@gui = new DAT.GUI
			@gui.add(@attributes, 'note').options(notes)
			@gui.add(@attributes, 'length').min(0).max(100)
	
	#########################
	# Sample Sidebar Module #
	#########################
	
	Modules.Sample = class extends Backbone.Model

		defaults:
			closed: true
			sample: 'kick'
			pitch: 440
			offset: 0

		initialize: ->
			@gui = new DAT.GUI
			@gui.add(@attributes, 'sample').options('kick', 'snare')
			@gui.add(@attributes, 'pitch').min(0).max(440)
			@gui.add(@attributes, 'offset').min(0).max(100)
	
	#########################
	# Global Sidebar Module #
	#########################

	Modules.Global = class extends Backbone.Model

		defaults:
			closed: false

		initialize: ->
			@gui = new DAT.GUI
			@gui.add(Phon.Properties, 'tick').min(0).max(300)
	
	#################
	# Sidebar Model #
	#################
	
	Sidebar = class extends Backbone.Model

		defaults:
			active: false
	
	################
	# Sidebar View #
	################
			
	SidebarView = class extends Backbone.View
	
		el: '#sidebar'
	
		events:
			'click h2': 'toggle_content'
			
		initialize: (options) ->
			
			_.bindAll this
			
			# views store options as properties anyway
			# but for some reason they arent accessible in constructor?
			model = options.model
			
			$('.module', @el).each ->
				
				$module = $ this
				module = new Modules[$module.attr 'data-module']
					type: $module.attr 'data-type'
				
				# store reference to the model in DOM to be easily accessed from events
				$module.data 'model', module
				
				# move DAT.GUI into container
				$('.content', $module).append module.gui.domElement
				
				# setting the closed property on the module
				# shows it and sets it as active
				module.bind 'change:closed', (module, closed) =>
					$module[if closed then 'removeClass' else 'addClass']('open')
					if not closed
						model.set active: module
				
				# setting a new active module closes old active module
				model.bind 'change:active', (sidebar, active) ->
					prev = sidebar.previous('active')
					if prev
						prev.set closed: true
				
		# shows / hides the current sidebar module
		toggle_content: (e) ->
			
			$module = $(e.target).closest('.module')
			model = $module.data('model')
			
			# module can have a "persistent" class to refuse closing
			if $module.hasClass('persistent')
				return false
			
			# set property/display on new module
			model.set 'closed': !(model.get 'closed')
	
	#####################
	# Make Thing Happen #
	#####################
	
	new SidebarView
	 	model: new Sidebar