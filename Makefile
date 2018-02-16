MAIN = src/Main.elm
OUTJS = bundle.js

ELM_MAKE = $(shell npm bin)/elm-make  # npm bin because then I don't require a global install for non-developers
ELM_LIVE = elm-live                   # you should have it in PATH if you're an elm dev :-)
ELMFLAGS =

.PHONY: default help clean clean-gitignore live

default: help

# -- END-USER RELEVANT -- #

build: $(OUTJS)  ## Compiles the app.

run: $(OUTJS) server.js  ## Runs the server.
	./server.js

# -- DEV TARGETS -- #

live:  ## Runs an elm-live server for development. Use alongside the normal run target and access under /dev.
	$(ELM_LIVE) $(MAIN) --output $(OUTJS) -- $(ELMFLAGS)

# -- THE TARGETS THAT ACTUALLY DO STUFF -- #

$(OUTJS): $(shell find src)
	npm install
	$(ELM_MAKE) $(ELMFLAGS) --yes $(MAIN) --output $(OUTJS)

# -- HELPERS -- #

help:  # stolen from marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-10s %s\n", $$1, $$2}'

clean:  ## Cleans generated files
	rm -rf elm-stuff/build-artifacts/
	rm -f $(OUTJS)

clean-all: clean-gitignore  ## Cleans everything, including downloaded dependencies

clean-gitignore:  ## Removes all files listed in ./.gitignore
	rm -rf $$(cat ./.gitignore | grep -v '^#')
