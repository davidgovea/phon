$ ->
	
	Module = class extends Backbone.Model
		
		defaults:
			
			closed: true
	
	window.Sidebar = class extends Backbone.View
	
		el: '#sidebar'
	
		events:
			'click h2': 'toggle_content'
			
		initialize: ->
			_.bindAll this
			$('.module', @el).each ->
				$module = $(this)
				$module.data 'model', new Module
				test = x: 10
				gui = new DAT.GUI()
				gui.add(test, 'x').min(0).max(10)
				$('.content', $module).append gui.domElement
				
		
		toggle_content: (e) ->
			$module = $(e.target).closest('.module')
			model = $module.data('model')
			closed = model.get 'closed'
			$('.icon', $module).text if closed then "-" else "+"
			$('.content', $module)[if closed then "show" else "hide"]()
			model.set 'closed': !closed
		
	new Sidebar