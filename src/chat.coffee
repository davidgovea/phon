$ ->

	MessageModel = class extends Backbone.Model

		defaults:
			username: false
			msg: ''

	MessageCollection = class extends Backbone.Collection

		model: MessageModel

	ChatModel = class extends Backbone.Model

		defaults:
			username: false

		initialize: ->
			@messages = new MessageCollection
			Phon.Socket.on 'chat', (message) =>
				@messages.add
					username: message.username
					msg: message.msg

	ChatView = class extends Backbone.Model

		el: '#chat'

		initialize: (options) ->
			
			_.bindAll this
			
			@model = options.model
			
			@$scroller = $('.scroller', @el)
			@$content = $('.content', @$scroller)
			@$username = $('input.username', @el)
			@$input = $('input.msg', @el)
			
			$(document).keyup (e) =>
				if e.which == 13
					if $(@el).hasClass 'ready'
						@$input.focus()
					else
						@$username.focus()
					
			@$input.keyup @send_message
			@$username.keyup @set_username
			
			@model.messages.bind 'add', (message) =>
				text = message.get 'msg'
				user = message.get 'username'
				@$content.append $ "<li><strong>#{user}:</strong> #{text}</li>"
				@$scroller.scrollTop @$content.height()
				
		send_message: (e) ->
			username = @model.get('username')
			if e.which == 13 and username
				message = new MessageModel
					username: username,
					msg: @$input.val()
				Phon.Socket.emit 'chat', message
				@$input.val ''
			e.stopPropagation()
			
		set_username: (e) ->	
			username = @$username.val()
			if e.which == 13 and username
				@model.set username: username
				$(@el).addClass 'ready'
				@$username.blur()
				@$input.focus()
			e.stopPropagation()

	new ChatView
		model: new ChatModel