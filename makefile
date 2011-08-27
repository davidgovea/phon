
all:
	cat src/wrapper-start.coffee src/vector.coffee src/automation.coffee src/sidebar.coffee src/wrapper-end.coffee > lib/phon.coffee
	coffee -c lib/phon.coffee
