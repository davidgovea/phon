$ ->

	$(document).keypress (e) ->
		if e.which == 13
			Phon.Socket.emit 'chat', prompt "what?"

	MessageModel = class extends Backbone.Model

		defaults:
			username: 'some user'
			msg: ''

	MessageCollection = class extends Backbone.Collection

		model: MessageModel

	ChatModel = class extends Backbone.Model

		initialize: ->
			@messages = new MessageCollection
			Phon.Socket.on 'chat', (msg) =>
				@messages.add
					msg: msg

	ChatView = class extends Backbone.Model

		el: '#chat'

		initialize: (options) ->
			@$content = $('.content', @el)
			options.model.messages.bind 'add', (message) =>
				text = message.get 'msg'
				user = message.get 'username'
				@$content.append $ "<li>#{user}: #{text}</li>"
				$(@el).scrollTop @$content.height()

	new ChatView
		model: new ChatModel