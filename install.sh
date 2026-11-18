#!/bin/bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"

if ! command -v brew &>/dev/null; then
  echo "📦 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "📦 Installing packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# 初回は ~/.config/mise/config.toml のリンクがまだ無いので、リポジトリ側を直接読ませる
echo "🔧 Running mise bootstrap..."
MISE_GLOBAL_CONFIG_FILE="$DOTFILES_DIR/mise/.config/mise/config.toml" mise bootstrap --yes

echo "👌 Done!"
echo "    次の手順:"
echo "    1. ~/.gitconfig.local を編集して name / email を設定"
echo "    2. Claude Code: claude コマンドで初回ログイン (/login)"
