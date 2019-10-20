watch:
	watcher -keepalive -startcmd -cmd "make docs/index.html" docs/codes.json index.html.erb create-index.rb

docs/logo.png: logo.png
	pngquant --speed 1 --quality 2 --output docs/logo.png logo.png

docs/favicon.png: favicon.png
	pngquant --speed 1 --quality 2 --output docs/favicon.png favicon.png

docs/index.html: docs/codes.json index.html.erb create-index.rb
	ruby create-index.rb docs/codes.json index.html.erb docs/index.html
	html-minifier \
		--minify-css true \
		--collapse-whitespace \
		--remove-attribute-quotes \
		--remove-comments \
		--remove-optional-tags \
		--remove-redundant-attributes \
		--remove-script-type-attributes \
		--use-short-doctype \
		docs/index.html \
		-o docs/index.html