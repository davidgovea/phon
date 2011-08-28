$ ->
		
	Modules = {}
		
	#############################
	# Instrument Sidebar Module #
	#############################
	
	Modules.Instrument = class extends Backbone.Model

		defaults:
			closed: true
			sound: false

		initialize: (options) ->
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
			sound = @get 'sound'
			@gui = new DAT.GUI
			@gui.add(sound.attributes, 'pitch').options(notes)
			@gui.add(sound.attributes, 'length').min(0).max(100)
	
	#########################
	# Sample Sidebar Module #
	#########################
	
	Modules.Sample = class extends Backbone.Model

		defaults:
			closed: true
			sound: false

		initialize: ->
			sound = @get 'sound'
			@gui = new DAT.GUI
			@gui.add(sound.attributes, 'sample').options('kick', 'snare')
			@gui.add(sound.attributes, 'pitch').min(0).max(440)
			@gui.add(sound.attributes, 'offset').min(0).max(100)
	
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
	
	SidebarModel = class extends Backbone.Model

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
				
			# paper can trigger events that sidebar responds to
			Phon.Elements.$paper.bind 'cell-selected', @select_cell

			# build assign/deactivate buttons
			$action_buttons = $ '<div class="buttons" />'
			$assign_btn = $ '<a class="disabled assign btn">Assign</a>'
			$deactivate_btn = $ '<a class="disabled deactivate btn">Deactivate</a>'
			$action_buttons.append $assign_btn	
			$action_buttons.append $deactivate_btn
			
			# save action buttons
			@$assign_btn = $assign_btn
			@$deactivate_btn = $deactivate_btn

			$('.module', @el).each ->
				
				$module = $ this
				$content = $('.content', $module)
				props = if $module.attr('data-sound') then sound: new Phon.Sounds[$module.attr 'data-sound'] else {}
				module = new Modules[$module.attr 'data-module'] props
				
				# store reference to the model in DOM to be easily accessed from events
				$module.data 'model', module
				
				# move DAT.GUI into container
				$content.append module.gui.domElement

				# setting the closed property on the module
				# shows it and sets it as active
				module.bind 'change:closed', (module, closed) =>
					# close module
					if closed
						$module.removeClass 'open'
					# open module and add buttons
					else
						$module.addClass 'open'
						$content.append $action_buttons
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

		select_cell: (e, row, col, sound) ->
			@$assign_btn.removeClass 'disabled'
			@$deactivate_btn[if !sound then 'removeClass' else 'addClass'] 'disabled'
			console.log 'got', row, col, sound
	
	#####################
	# Make Thing Happen #
	#####################
	
	window.Sidebar = new SidebarView
	 	model: new SidebarModel