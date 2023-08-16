.PHONY: all clean print-version

SRC_ROOT := src
TELEMETRY := $(SRC_ROOT)/SCRIPTS/TELEMETRY
WIDGETS := $(SRC_ROOT)/WIDGETS
TOOLS := $(SRC_ROOT)/SCRIPTS/TOOLS

SRC := $(wildcard $(WIDGETS)/*.lua)
SRC += $(wildcard $(WIDGETS)/iNav/*.lua)
SRC += $(wildcard $(TELEMETRY)/*.lua)
SRC += $(wildcard $(TELEMETRY)/iNav/*.lua)
SRC += $(wildcard $(TELEMETRY)/iNav/*/*.wav)
SRC += $(wildcard $(TELEMETRY)/iNav/pics/*.*)
SRC += $(wildcard $(TELEMETRY)/iNav/cfg/*.*)
SRC += $(wildcard $(TOOLS)/*.lua)

DIST := dist
VERSION := $(shell grep VERSION $(TELEMETRY)/iNav.lua | head -n 1 | cut -d\" -f 2)
BUILD_SUFFIX ?=
ifneq ($(BUILD_SUFFIX),)
	BUILD_SUFFIX := _$(BUILD_SUFFIX)
endif
ZIP := $(DIST)/LuaTelemetry_v$(VERSION)$(BUILD_SUFFIX).zip
ZIPLUA := $(DIST)/LuaTelemetry_v$(VERSION)$(BUILD_SUFFIX)_lua.zip

OBJ := obj
OBJ_SRC := $(subst $(SRC_ROOT),$(OBJ),$(SRC))
OBJS := $(OBJ_SRC:.lua=.luac)

# These need to be added as .lua too, because OTX will only look for
# .lua files, ignoring .luac. It doesn't matter than there's actually
# .luac since lua can load both source and bytecode using the same API,
# using heuristics to figure what it is.
OBJS += $(OBJ)/WIDGETS/iNav/main.lua
OBJS += $(OBJ)/SCRIPTS/TELEMETRY/iNav.lua

LUA_DIST = 3rdparty/lua-5.2.4
LUA = $(LUA_DIST)/src/lua
LUAC = $(LUA)c

all: obj

$(LUA) $(LUAC): $(LUA_DIST)
	$(MAKE) -C $< generic

$(OBJ)/%.luac: $(SRC_ROOT)/%.lua $(LUAC)
	mkdir -p $(dir $@)
	$(LUAC) -s -o  "$@" "$<"

$(OBJ)/%.lua: $(OBJ)/%.luac
	cp -f "$<" "$@"

$(OBJ)/%.wav: $(SRC_ROOT)/%.wav
	mkdir -p $(dir $@)
	cp -f "$<" "$@"

$(OBJ)/%.png: $(SRC_ROOT)/%.png
	mkdir -p $(dir $@)
	cp -f "$<" "$@"

$(OBJ)/%.txt: $(SRC_ROOT)/%.txt
	mkdir -p $(dir $@)
	cp -f "$<" "$@"

obj: $(OBJS)

dist: $(DIST_SRC) $(OBJS)
lua: $(LUA)
luac: $(LUAC)

$(ZIP):
	mkdir -p $(DIST)
	cd $(OBJ) && \
		zip ../$@ -r *

zip: $(ZIP)
dist: zip

ifneq ($(SDCARD),)
install: obj
	mkdir -p "$(SDCARD)"
	cp -r $(OBJ)/* "$(SDCARD)"
else
install:
	$(error $$SDCARD is empty - use SDCARD=dest make install)
endif

clean-obj:
	$(RM) -r $(OBJ)

clean-zip:
	$(RM) $(ZIP) $(ZIPLUA)

clean-lua:
	$(MAKE) -C $(LUA_DIST) clean

clean: clean-obj clean-zip clean-lua

print-version:
	@echo $(VERSION)

zip-lua: $(ZIPLUA)
$(ZIPLUA): $(SRC)
	cd src && zip -9r ../$@ .

dist-lua: zip-lua

ifneq ($(SDCARD),)
install-lua: obj
	mkdir -p "$(SDCARD)"
	cp -av src/* "$(SDCARD)"
else
install-lua:
	$(error $$SDCARD is empty - use SDCARD=dest make install-lua)
endif
