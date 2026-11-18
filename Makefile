# dotfiles — よく使うコマンド
DOTFILES_DIR := $(abspath .)

.PHONY: link status brew bootstrap install

link:
	mise dotfiles apply

status:
	mise bootstrap status

brew:
	brew bundle --file="$(DOTFILES_DIR)/Brewfile"

bootstrap:
	mise bootstrap

install:
	./install.sh
