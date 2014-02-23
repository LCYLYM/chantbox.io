server:
	@sudo mongod & node-dev server.coffee

test:
	@NODE_ENV=test ./node_modules/.bin/mocha --compilers coffee:coffee-script/register --recursive --reporter spec

.PHONY: test
