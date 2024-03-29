vpath %.coffee src:src/plugin

ANNOTATOR_SRC := annotator.coffee
ANNOTATOR_PKG := pkg/annotator.js pkg/annotator.css

PLUGIN_SRC := $(wildcard src/plugin/*.coffee)
PLUGIN_SRC := $(patsubst src/plugin/%,%,$(PLUGIN_SRC))
PLUGIN_PKG := $(patsubst %.coffee,pkg/annotator.%.js,$(PLUGIN_SRC))

FULL_SRC := $(ANNOTATOR_SRC) $(PLUGIN_SRC)
FULL_PKG := pkg/annotator-full.js pkg/annotator.css

BOOKMARKLET_PKG := pkg/annotator-bookmarklet.js pkg/annotator.css \
	pkg/bootstrap.js

DIGILIB_PKG := pkg/annotator-digilib.js pkg/annotator.css

BUILD := ./tools/build
DEPS := ./tools/build -d

DEPDIR := .deps
df = $(DEPDIR)/$(*F)

PKGDIRS := pkg/lib pkg/lib/plugin

all: annotator plugins annotator-full bookmarklet annotator-digilib
default: all

annotator: $(ANNOTATOR_PKG)
plugins: $(PLUGIN_PKG)
annotator-full: $(FULL_PKG)
bookmarklet: $(BOOKMARKLET_PKG)
annotator-digilib: $(DIGILIB_PKG)

pkg: $(ANNOTATOR_PKG) $(PLUGIN_PKG) $(FULL_PKG) $(BOOKMARKLET_PKG)
	$(shell npm bin)/coffee -c -o pkg/lib src
	cp package.json main.js index.js pkg/
	cp AUTHORS pkg/
	cp LICENSE* pkg/
	cp README* pkg/

clean:
	rm -rf .deps pkg

test:
	npm test

develop:
	npm start

doc: docco
	cd doc && $(MAKE) html
	docco src/*.coffee -o doc/_build/html/docco/

# Make the docco build timestamped off the docco.css file which is regenerated
# on every docco build. This, in concert with the next task, can ensure that we
# don't regenerate docco docs unless the source files have actually changed.
docco: doc/_build/html/src/docco.css

doc/_build/html/src/docco.css: $(wildcard src/**/*.coffee)
	$(shell npm bin)/docco src/**/*.coffee -o doc/_build/html/src

pkg/annotator.css: css/annotator.css
	$(BUILD) -c

pkg/%.js pkg/annotator.%.js: %.coffee

pkg/%.js pkg/annotator.%.js pkg/annotator-%.js: | $(DEPDIR) $(PKGDIRS)
	$(eval $@_CMD := $(patsubst annotator.%.js,-p %.js,$(@F)))
	$(eval $@_CMD := $(subst .js,,$($@_CMD)))
	$(BUILD) $($@_CMD)
	@$(DEPS) $($@_CMD) \
		| sed -n 's/^\(.*\)/pkg\/$(@F): \1/p' \
		| sort | uniq > $(df).d

$(DEPDIR) $(PKGDIRS):
	@mkdir -p $@

-include $(DEPDIR)/*.d

.PHONY: all annotator plugins annotator-full bookmarklet annotator-digilib clean test develop \
	pkg doc docco
