# dependencies

SQLITE_AMALGAMATION = sqlite-amalgamation-3320300
SQLITE_AMALGAMATION_ZIP_URL = https://www.sqlite.org/2020/sqlite-amalgamation-3320300.zip
SQLITE_AMALGAMATION_ZIP_SHA1 = 0c805bea134712a903290a26b2a61c3a8a3bd8cc

EXTENSION_FUNCTIONS = extension-functions.c
EXTENSION_FUNCTIONS_URL = http://www.sqlite.org/contrib/download/extension-functions.c?get=25
EXTENSION_FUNCTIONS_SHA1 = da39a3ee5e6b4b0d3255bfef95601890afd80709 

# source files

EXPORTED_FUNCTIONS_JSON = src/exported_functions.json

# temporary files

BITCODE_FILES = temp/bc/sqlite3.bc temp/bc/extension-functions.bc temp/bc/wasmhelpers.bc

# build options
EMCC = emcc

CFLAGS = \
	-D_HAVE_SQLITE_CONFIG_H \
	-Isrc/c -I'deps/$(SQLITE_AMALGAMATION)'

EMFLAGS = 

EMFLAGS_DEBUG = \
	-s INLINING_LIMIT=10 \
	-O1

EMFLAGS_DIST = \
	-s INLINING_LIMIT=50 \
	-s IGNORE_CLOSURE_COMPILER_ERRORS=1 \
	-O1

# directories

.PHONY: all
all: dist

.PHONY: clean
clean:
	rm -rf dist debug temp

.PHONY: clean-all
clean-all:
	rm -rf dist debug temp deps cache

## cache

.PHONY: clean-cache
clean-cache:
	rm -rf cache

cache/$(SQLITE_AMALGAMATION).zip:
	mkdir -p cache
	curl '$(SQLITE_AMALGAMATION_ZIP_URL)' -o $@

cache/$(EXTENSION_FUNCTIONS):
	mkdir -p cache
	curl '$(EXTENSION_FUNCTIONS_URL)' -o $@

## deps

.PHONY: clean-deps
clean-deps:
	rm -rf deps

.PHONY: deps
deps: deps/$(SQLITE_AMALGAMATION) deps/$(EXTENSION_FUNCTIONS) deps/$(EXPORTED_FUNCTIONS)

deps/$(SQLITE_AMALGAMATION): cache/$(SQLITE_AMALGAMATION).zip
	mkdir -p deps
	echo '$(SQLITE_AMALGAMATION_ZIP_SHA1)' 'cache/$(SQLITE_AMALGAMATION).zip' | sha1sum -c
	rm -rf $@
	unzip 'cache/$(SQLITE_AMALGAMATION).zip' -d deps/
	touch $@

deps/$(EXTENSION_FUNCTIONS): cache/$(EXTENSION_FUNCTIONS)
	mkdir -p deps
	echo '$(EXTENSION_FUNCTIONS_SHA1)' 'cache/$(EXTENSION_FUNCTIONS)' | sha1sum -c
	cp 'cache/$(EXTENSION_FUNCTIONS)' $@

## temp

.PHONY: clean-temp
clean-temp:
	rm -rf temp

temp/bc/shell.bc: deps/$(SQLITE_AMALGAMATION) src/c/config.h
	mkdir -p temp/bc
	$(EMCC) $(CFLAGS) 'deps/$(SQLITE_AMALGAMATION)/shell.c' -r -o $@

temp/bc/sqlite3.bc: deps/$(SQLITE_AMALGAMATION) src/c/config.h
	mkdir -p temp/bc
	$(EMCC) $(CFLAGS) -s LINKABLE=1 'deps/$(SQLITE_AMALGAMATION)/sqlite3.c' -r -o $@

temp/bc/extension-functions.bc: deps/$(EXTENSION_FUNCTIONS) src/c/config.h
	mkdir -p temp/bc
	$(EMCC) $(CFLAGS) -s LINKABLE=1 'deps/$(EXTENSION_FUNCTIONS)' -r -o $@

temp/bc/wasmhelpers.bc: src/c/wasmhelpers.c src/c/config.h
	mkdir -p temp/bc
	$(EMCC) $(CFLAGS) -s LINKABLE=1 src/c/wasmhelpers.c -r -o $@

## debug
.PHONY: clean-debug
clean-debug:
	rm -rf debug

.PHONY: debug
debug: debug/e_sqlite3.bc

debug/e_sqlite3.bc: $(BITCODE_FILES) $(EXPORTED_FUNCTIONS_JSON)
	mkdir -p debug
	$(EMCC) $(EMFLAGS) $(EMFLAGS_DEBUG) $(BITCODE_FILES) -r -o $@

## dist
.PHONY: clean-dist
clean-dist:
	rm -rf dist

.PHONY: dist
dist: dist/e_sqlite3.bc

dist/e_sqlite3.bc: $(BITCODE_FILES) $(EXPORTED_FUNCTIONS_JSON)
	mkdir -p dist
	$(EMCC) $(EMFLAGS) $(EMFLAGS_DIST) $(BITCODE_FILES) -r -o $@
