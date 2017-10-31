.PHONY: default help clean clean-gitignore

default: help

MAIN = src/Main.elm
OUTJS = elm.js

live:  ## Runs an elm-live server for development
	elm-live $(MAIN) --output $(OUTJS)

open:  ## Runs a dev server and opens the app in the browser
	elm-live $(MAIN) --output $(OUTJS)

build:  ## Compiles the app.
	elm-make $(MAIN) --output $(OUTJS)


help:  # stolen from marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-10s %s\n", $$1, $$2}'

clean: clean-gitignore

clean-gitignore:  ## Removes files listed in ./.gitignore
	rm -f $$(cat ./.gitignore | grep -v '^#')
