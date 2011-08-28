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
			
			# hitting enter anywhere focuses chat
			$(document).keyup (e) =>
				if e.which == 13
					if $(@el).hasClass 'ready'
						@$input.focus()
					else
						@$username.focus()
			
			# bind enter to chat / set username
			@$input.keyup @send_message
			@$username.keyup @set_username

			add_chat_content = (content) =>
				@$content.append $ "<li>#{content}</li>"
				@$scroller.scrollTop @$content.height()

			Phon.Socket.on 'connect', =>
				add_chat_content "<strong><em>*you are now connected to phon*</em></strong>"
			
			# new messages rerenders ui
			@model.messages.bind 'add', (message) =>
				text = message.get 'msg'
				username = message.get 'username'
				add_chat_content "<strong>#{username}:</strong> #{text}"
				
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