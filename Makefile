
# TODO later: figure out why sourcemaps aren't working
app.js:
	browserify --debug --transform coffeeify src/app.coffee -o app.js

kill-serve:
	-kill `cat server.pid`
	-rm server.pid

serve: app.js kill-serve
	@python -m SimpleHTTPServer 3000 & echo "$$!" > server.pid

auto-serve:
	nodemon --ext '.coffee|.html' -w ./ *.coffee index.html --exec 'make serve'

.PHONY: app.js serve auto-serve
