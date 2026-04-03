#!/bin/bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"

# ============================================================
# 1. Homebrew
# ============================================================
if ! command -v brew &>/dev/null; then
  echo "📦 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ============================================================
# 2. stow (symlink に必要なので先にインストール)
# ============================================================
if ! command -v stow &>/dev/null; then
  echo "🔗 Installing stow..."
  brew install stow
fi

# ============================================================
# 3. Symlinks
# ============================================================
echo "🔗 Creating symlinks..."
cd "$DOTFILES_DIR"
stow -v -t "$HOME" zsh git vim starship ghostty mise

# ============================================================
# 4. Packages
# ============================================================
echo "📦 Installing packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# ============================================================
# 5. VS Code Extensions
# ============================================================
if command -v code &>/dev/null; then
  echo "🧩 Installing VS Code extensions..."
  while IFS= read -r ext; do
    code --install-extension "$ext" --force
  done < "$DOTFILES_DIR/vscode/extensions.txt"
fi

echo "👌 Done!"
