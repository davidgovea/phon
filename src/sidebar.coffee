$ ->
		
	Modules = {}

	Module = class extends Backbone.Model
		defaults:
			closed: true
			sound: false
		
	#############################
	# Instrument Sidebar Module #
	#############################
	
	Modules.Instrument = class extends Module

		initialize: (options) ->
			@refresh_gui()
			
		refresh_gui: ->
			sound = @get 'sound'
			gui = new DAT.GUI
			gui.add(sound.attributes, 'pitch').options('a', 'a#', 'b', 'c','c#','d','d#','e', 'f', 'f#', 'g')
			gui.add(sound.attributes, 'length').min(0).max(100)
			@gui_elements = [gui.domElement]
	
	#########################
	# Sample Sidebar Module #
	#########################
	
	Modules.Sample = class extends Module

		initialize: ->
			@refresh_gui()

		refresh_gui: ->
			sound = @get 'sound'
			gui = new DAT.GUI
			gui.add(sound.attributes, 'sample').options('kick', 'snare')
			gui.add(sound.attributes, 'pitch').min(0).max(440)
			gui.add(sound.attributes, 'offset').min(0).max(100)
			@gui_elements = [gui.domElement]
	
	#########################
	# Global Sidebar Module #
	#########################

	Modules.Global = class extends Backbone.Model

		defaults:
			closed: false

		initialize: ->

			notify_grid = (type, amount) ->
				Phon.Socket.emit 'effect',
					type: type
					amount: amount

			$titles = {}
			$titles.reverb = $ '<h3>Reverb (not working yet)</h3>'
			$titles.bitcrusher = $ '<h3>Bitcrusher (not working yet)</h3>'

			Phon.Socket.on 'effect', (params) ->
				amount = params.amount
				count = if amount > 0 then ("+" + amount) else amount
				$notify = $('<span class="notify" />').text count
				$titles[params.type].append $notify
				setTimeout(->
					$notify.fadeOut ->
						$notify.remove()
				, 1500)

			reverb =
				more: -> notify_grid 'reverb', 1
				less: -> notify_grid 'reverb', -1

			bitcrusher =
				more: -> notify_grid 'bitcrusher', 1
				less: -> notify_grid 'bitcrusher', -1

			gui1 = new DAT.GUI
			gui1.add(reverb, 'more')
			gui1.add(reverb, 'less')

			gui2 = new DAT.GUI
			gui2.add(bitcrusher, 'more')
			gui2.add(bitcrusher, 'less')

			@gui_elements = [$titles.reverb, gui1.domElement, $titles.bitcrusher, gui2.domElement]
	
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
			'click a.assign': 'assign_sound'
			'click a.deactivate': 'deactivate_sound'

		$assign_button: false
		$deactivate_button: false
		current_cell: false
			
		initialize: (options) ->
			
			_.bindAll this
			
			# views store options as properties anyway
			# but for some reason they arent accessible in constructor?
			model = options.model
			@model = model

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

			modules = {}

			$('.module', @el).each ->
				
				$module = $ this
				$content = $('.content', $module)
				props = if $module.attr('data-sound') then sound: new Phon.Sounds[$module.attr 'data-sound'] else {}
				module = new Modules[$module.attr 'data-module'] props
				
				# store reference to the model in DOM to be easily accessed from events
				$module.data 'model', module
				
				populate = (elements) ->
					for el in elements
						$content.append el

				# move DAT.GUI into container
				populate module.gui_elements

				if module.get 'sound'
					modules[$module.attr 'data-sound'] = module

				module.bind 'change:sound', (module, sound) =>
					$content.empty()
					populate module.refresh_gui()
					$content.append $action_buttons
					module.set closed: false

				# setting the closed property on the module
				# shows it and sets it as active
				module.bind 'change:closed', (module, closed) =>
					console.info 'GOT CLOSED'
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

			@modules = modules

		# shows / hides the current sidebar module
		toggle_content: (e) ->
			$module = $(e.target).closest('.module')
			model = $module.data('model')
			
			# module can have a "persistent" class to refuse closing
			if $module.hasClass('persistent')
				return false
			
			# set property/display on new module
			model.set 'closed': !(model.get 'closed')
		
		# accepts an cell from the grid and saves reference as current cell
		select_cell: (e, cell) ->

			sound = cell.sound
			@current_cell = cell
			@$assign_btn.removeClass 'disabled'

			console.info 'SELECT CELL', sound

			if sound
				module = @modules[sound.type]
				@$deactivate_btn.removeClass 'disabled'
				module.set sound: new Phon.Sounds[sound.type] sound
				module.set closed: false

			else
				active = @model.get('active')
				if active
					active.set
						closed: true
				@$deactivate_btn.addClass 'disabled'
				

		# tells api to create a new sound on a given cell
		assign_sound: (e) ->

			$module = $(e.target).closest('.module')
			module = @modules[$module.attr('data-sound')]
			sound_name = $module.attr('data-sound')

			if not @current_cell
				return false
			
			# reset UI snd reset module model
			@$assign_btn.addClass 'disabled'
			@$deactivate_btn.addClass 'disabled'

			# dummy sound just created to trigger api
			sound = new Phon.Sounds[sound_name] module.get('sound').attributes

			module.set sound: new Phon.Sounds[sound_name], silent: true
			module.set closed: true
			sound.register @current_cell.row, @current_cell.col

		# tells api to delete sound from a cell
		deactivate_sound: (e) ->

			if not @current_cell
				return false
			
			@$deactivate_btn.addClass 'disabled'
			@current_cell.removeSound()
	
	#####################
	# Make Thing Happen #
	#####################
	window.Sidebar = new SidebarView
	 	model: new SidebarModel


	###
	[DAT.GUI ERROR] [object Object] either has no property 'sample', or the property is inaccessible.
	phon.js:1111Uncaught TypeError: Cannot call method 'options' of undefined
	###