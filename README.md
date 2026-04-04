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
2. `stow` で各設定のシンボリックリンクを作成（`zsh` / `git` / `vim` / `starship` / `ghostty` / `mise` / `claude`）
3. `brew bundle` でパッケージ・アプリを一括インストール
4. `mise install` で [mise/.config/mise/config.toml](mise/.config/mise/config.toml) のランタイムを入れる
5. VS Code 拡張の一括インストール（`code` がある場合）

### Stow の衝突時

既に同名ファイルがあると stow が失敗することがある。そのときはバックアップを取ったうえで GNU Stow の `stow --adopt`（要確認: バージョンにより挙動が異なる）で取り込む、または手で退避してから `stow` し直す。

### 日常コマンド（Makefile）

- `make stow` — シンボリックリンクを更新
- `make brew` — Brewfile を反映
- `make mise-install` — mise ツールをインストール

## Structure

```
.dotfiles/
├── zsh/          .zshenv, .zprofile, .zshrc, .zsh-alias
├── git/          .gitconfig
├── vim/          .vimrc, .vim/
├── starship/     .config/starship.toml
├── ghostty/      .config/ghostty/config
├── mise/         .config/mise/config.toml
├── claude/       .claude/（Claude Code 用グローバル設定）
├── vscode/       extensions.txt（VS Code 拡張一覧）
├── docs/         設定ガイド
├── Brewfile
├── install.sh
├── Makefile
└── README.md
```

## Adding a new config

1. パッケージディレクトリを作成（例: `mkdir -p newapp/.config/newapp`）
2. 設定ファイルを配置
3. `install.sh` の `stow` 行にパッケージ名を追加
4. `stow --no-folding -t ~ newapp` で反映（dry-run は `stow -n -v --no-folding -t ~ newapp`）

## Brewfile のメンテ

別マシンとの差分を取りたいとき:

```bash
brew bundle dump --file=/tmp/Brewfile.dump --force
diff ~/.dotfiles/Brewfile /tmp/Brewfile.dump
```
