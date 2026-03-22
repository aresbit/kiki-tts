PREFIX ?= /usr/local
DESTDIR ?=

PROJECT_NAME := kiki
MODEL_NAME := kitten-tts-mini

BINDIR := $(PREFIX)/bin
DATADIR := $(PREFIX)/share/$(PROJECT_NAME)
BIN_SRC ?= target/release/kitten-tts
MODEL_SRC_DIR := models/$(MODEL_NAME)
MODEL_DST_DIR := $(DATADIR)/models/$(MODEL_NAME)

INSTALL := install
MKDIR_P := mkdir -p

.PHONY: all install uninstall install-bin install-wrapper install-model validate

all:
	@printf '%s\n' 'Nothing to build. Use `make install` to install kiki and kitten-tts.'

validate:
	@test -x $(BIN_SRC)
	@test -f $(MODEL_SRC_DIR)/config.json
	@test -f $(MODEL_SRC_DIR)/kitten_tts_mini_v0_8.onnx
	@test -f $(MODEL_SRC_DIR)/voices.npz
	@test -f scripts/kiki.in

install: validate install-bin install-wrapper install-model
	@printf '%s\n' 'Installed:' \
		'  $(DESTDIR)$(BINDIR)/kitten-tts (from $(BIN_SRC))' \
		'  $(DESTDIR)$(BINDIR)/kiki' \
		'  $(DESTDIR)$(MODEL_DST_DIR)'

install-bin:
	@$(MKDIR_P) "$(DESTDIR)$(BINDIR)"
	@$(INSTALL) -m 0755 "$(BIN_SRC)" "$(DESTDIR)$(BINDIR)/kitten-tts"

install-wrapper:
	@$(MKDIR_P) "$(DESTDIR)$(BINDIR)"
	@sed \
		-e 's|@PREFIX@|$(PREFIX)|g' \
		-e 's|@MODEL_NAME@|$(MODEL_NAME)|g' \
		scripts/kiki.in > "$(DESTDIR)$(BINDIR)/kiki"
	@chmod 0755 "$(DESTDIR)$(BINDIR)/kiki"

install-model:
	@$(MKDIR_P) "$(DESTDIR)$(MODEL_DST_DIR)"
	@$(INSTALL) -m 0644 "$(MODEL_SRC_DIR)/config.json" "$(DESTDIR)$(MODEL_DST_DIR)/config.json"
	@$(INSTALL) -m 0644 "$(MODEL_SRC_DIR)/kitten_tts_mini_v0_8.onnx" "$(DESTDIR)$(MODEL_DST_DIR)/kitten_tts_mini_v0_8.onnx"
	@$(INSTALL) -m 0644 "$(MODEL_SRC_DIR)/voices.npz" "$(DESTDIR)$(MODEL_DST_DIR)/voices.npz"

uninstall:
	@rm -f "$(DESTDIR)$(BINDIR)/kiki"
	@rm -f "$(DESTDIR)$(BINDIR)/kitten-tts"
	@rm -f "$(DESTDIR)$(MODEL_DST_DIR)/config.json"
	@rm -f "$(DESTDIR)$(MODEL_DST_DIR)/kitten_tts_mini_v0_8.onnx"
	@rm -f "$(DESTDIR)$(MODEL_DST_DIR)/voices.npz"
	@rmdir --ignore-fail-on-non-empty "$(DESTDIR)$(MODEL_DST_DIR)" 2>/dev/null || true
	@rmdir --ignore-fail-on-non-empty "$(DESTDIR)$(DATADIR)/models" 2>/dev/null || true
	@rmdir --ignore-fail-on-non-empty "$(DESTDIR)$(DATADIR)" 2>/dev/null || true
	@printf '%s\n' 'Uninstalled kiki from $(DESTDIR)$(PREFIX)'
