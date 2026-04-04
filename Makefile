# dotfiles — よく使うコマンド
STOW_PACKAGES := zsh git vim starship ghostty mise claude
DOTFILES_DIR := $(abspath .)

.PHONY: stow brew mise-install install

stow:
	cd "$(DOTFILES_DIR)" && stow -v --no-folding -t "$(HOME)" $(STOW_PACKAGES)

brew:
	brew bundle --file="$(DOTFILES_DIR)/Brewfile"

mise-install:
	mise install

install:
	./install.sh
