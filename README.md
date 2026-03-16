# dotfiles

GNU Stow で管理する dotfiles。

## Setup

```bash
git clone https://github.com/registak/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` は以下を実行します：

1. Homebrew のインストール（未導入の場合）
2. `brew bundle` でパッケージ・アプリを一括インストール
3. `stow` で各設定ファイルのシンボリックリンクを作成

## Structure

```
.dotfiles/
├── zsh/          .zshrc, .zshenv, .zsh-alias
├── git/          .gitconfig
├── vim/          .vimrc, .vim/
├── starship/     .config/starship.toml
├── ghostty/      .config/ghostty/config
├── mise/         .config/mise/config.toml
├── docs/         設定ガイド
├── Brewfile
├── install.sh
└── README.md
```

## Adding a new config

1. パッケージディレクトリを作成（例: `mkdir -p newapp/.config/newapp`）
2. 設定ファイルを配置
3. `install.sh` の `stow` 行にパッケージ名を追加
4. `stow -t ~ newapp` で反映
