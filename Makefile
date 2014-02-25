server:
	@node-dev server.coffee

database:
	@sudo mongod

test:
	@NODE_ENV=test ./node_modules/.bin/mocha --compilers coffee:coffee-script/register --recursive --reporter spec

.PHONY: test
