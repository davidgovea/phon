
all:
	cat public/javascripts/wrapper-start.coffee public/javascripts/sounds.coffee public/javascripts/vector.coffee public/javascripts/automation.coffee public/javascripts/sidebar.coffee public/javascripts/wrapper-end.coffee > public/javascripts/phon.coffee
	coffee -c public/javascripts/phon.coffee
	coffee -c server.coffee
