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
stow -v --no-folding -t "$HOME" zsh git vim starship ghostty mise claude glow

# ============================================================
# 4. Local config templates (初回のみ)
# ============================================================
if [ ! -f "$HOME/.gitconfig.local" ]; then
  echo "📝 Creating ~/.gitconfig.local from template..."
  cp "$DOTFILES_DIR/.gitconfig.local.example" "$HOME/.gitconfig.local"
  echo "    ⚠️  ~/.gitconfig.local を編集して name / email を設定してください"
fi
if [ ! -f "$HOME/.gitignore_global" ]; then
  echo "📝 Creating ~/.gitignore_global from template..."
  cp "$DOTFILES_DIR/.gitignore_global.example" "$HOME/.gitignore_global"
fi

# ============================================================
# 5. Packages
# ============================================================
echo "📦 Installing packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# ============================================================
# 6. mise（config.toml のランタイムをインストール）
# ============================================================
if command -v mise &>/dev/null; then
  echo "🔧 Installing mise tools..."
  mise install
fi

# ============================================================
# 7. Claude Code (native install、バックグラウンド自動更新)
# ============================================================
if ! command -v claude &>/dev/null; then
  echo "🤖 Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
fi

# ============================================================
# 8. VS Code Extensions
# ============================================================
if command -v code &>/dev/null; then
  echo "🧩 Installing VS Code extensions..."
  while IFS= read -r ext; do
    code --install-extension "$ext" --force
  done < "$DOTFILES_DIR/vscode/extensions.txt"
fi

echo "👌 Done!"
echo "    次の手順:"
echo "    1. ~/.gitconfig.local を編集して name / email を設定"
echo "    2. Claude Code: claude コマンドで初回ログイン (/login)"
