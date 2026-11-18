# dotfiles

mise bootstrap で管理する dotfiles。

## Setup

### Xcode Command Line Tools が未インストールの場合

```bash
xcode-select --install
```

### インストール

```bash
git clone https://github.com/registak/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` は以下を実行します：

1. Homebrew のインストール（未導入の場合）
2. `brew bundle` でパッケージ・アプリを一括インストール（mise もここで入る）
3. `mise bootstrap` を実行

`mise bootstrap` は [mise/.config/mise/config.toml](mise/.config/mise/config.toml) に従って以下を行います：

1. `[bootstrap] dotfile_groups` に並べたディレクトリを、ファイル単位のシンボリックリンクで `~` に展開
2. `[tools]` のランタイムを `mise.lock` のバージョンで入れる
3. `bootstrap` タスクを実行
   - `~/.gitconfig.local` / `~/.gitignore_global` を `*.example` から初期化（未存在時のみ）
   - [Claude Code](https://code.claude.com/) を native install（未導入時のみ、以降バックグラウンド自動更新）
   - VS Code 拡張のうち未導入のものをインストール（`code` がある場合）

セットアップ完了後にやること:

- `~/.gitconfig.local` を編集して `name` / `email` を自分の情報に置き換える
- `claude` を起動して `/login` で認証

### リンク先に同名ファイルがあるとき

`mise dotfiles diff` で差分を確認し、リポジトリ側に取り込むなら `mise dotfiles add --group <名前> <ファイル>`、リポジトリ側で上書きするならバックアップを取ったうえで `mise dotfiles apply --force` を使う。

### 日常コマンド（Makefile）

- `make install` — install.sh をフル実行
- `make bootstrap` — `mise bootstrap` を実行（リンク・ランタイム・bootstrap タスク）
- `make link` — シンボリックリンクだけ更新
- `make status` — リンクとランタイムの状態を表示
- `make brew` — Brewfile を反映

## Structure

```
.dotfiles/
├── zsh/          .zshenv, .zprofile, .zshrc, .zsh-alias
├── git/          .gitconfig
├── vim/          .vimrc, .vim/
├── starship/     .config/starship.toml
├── ghostty/      .config/ghostty/config
├── mise/         .config/mise/config.toml, mise.lock
├── claude/       .claude/（CLAUDE.md, settings.json, rules/, statusline-command.sh）
├── glow/         Library/Preferences/glow/（glow 設定）
├── vscode/       extensions.txt（リンク対象外、code CLI で管理）
├── docs/         ghostty / starship / eval-cache / tools ガイド
├── .gitconfig.local.example      個人情報（name / email）の雛形
├── .gitignore_global.example     グローバル除外リストの雛形
├── Brewfile
├── install.sh
├── Makefile
└── README.md
```

## Adding a new config

1. パッケージディレクトリを作成（例: `mkdir -p newapp/.config/newapp`）
2. 設定ファイルを配置
3. [mise/.config/mise/config.toml](mise/.config/mise/config.toml) の `dotfile_groups` にディレクトリ名を追加
4. `mise dotfiles apply` で反映（dry-run は `mise dotfiles apply --dry-run`）

リポジトリからファイルを消したあとに残ったリンクは `mise dotfiles apply --prune` で片付ける。

## ランタイムの更新

`[tools]` は `latest` 指定で、実際に入るバージョンは `mise.lock` が決める。上げるときは `mise upgrade` を実行し、変わった `mise.lock` をコミットする。

## Brewfile のメンテ

別マシンとの差分を取りたいとき:

```bash
brew bundle dump --file=/tmp/Brewfile.dump --force
diff ~/.dotfiles/Brewfile /tmp/Brewfile.dump
```
