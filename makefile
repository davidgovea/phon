
all:
	cat src/wrapper-start.coffee src/sounds.coffee src/vector.coffee src/automation.coffee src/sidebar.coffee src/wrapper-end.coffee > src/phon.coffee
	coffee -c src/phon.coffee
	cp src/phon.js public/javascripts/phon.js
	rm src/phon.js
	rm src/phon.coffee
	coffee -c server.coffee