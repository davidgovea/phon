$ ->
		
	Module = class extends Backbone.Model
		
		defaults:
			closed: true
		
	Modules = {}

	Modules.Global = class extends Module
		
		initialize: ->
			@gui = new DAT.GUI
			@gui.add(Phon.Properties, 'tick').min(0).max(300)
	
	window.Sidebar = class extends Backbone.View
	
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
				
		
		toggle_content: (e) ->
			$module = $(e.target).closest('.module')
			model = $module.data('model')
			closed = model.get 'closed'
			$('.icon', $module).text if closed then "-" else "+"
			$('.content', $module)[if closed then "show" else "hide"]()
			model.set 'closed': !closed
		
	new Sidebar