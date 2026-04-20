# dotfiles

macOS (Apple Silicon) 向けの個人 dotfiles。GNU Stow でシンボリックリンク管理。

## 構成

```
zsh/       .zshenv, .zprofile, .zshrc, .zsh-alias
git/       .gitconfig
vim/       .vimrc, .vim/
starship/  .config/starship.toml
ghostty/   .config/ghostty/config
mise/      .config/mise/config.toml
claude/    .claude/（Claude Code 用）
glow/      Library/Preferences/glow/（glow 設定）
vscode/    extensions.txt（stow 対象外、code CLI で管理）
docs/      各ツールのガイド
```

## Stow

```bash
cd ~/.dotfiles && stow --no-folding -t ~ zsh git vim starship ghostty mise claude glow
# vscode は stow 対象外。extensions は install.sh が `code --install-extension` で入れる
```

新しいファイルを追加した場合は対応パッケージに配置して `stow` を再実行する。

## スタック

- ターミナル: Ghostty
- シェル: zsh + Zinit (Turbo モード)
- プロンプト: Starship
- バージョン管理: mise
- Fuzzy finder: fzf + zoxide
- エディタ: VS Code

## zsh ファイルの役割

- `.zshenv` — 環境変数・PATH（全シェルで読まれる。VS Code 拡張等のノンログインシェル対応）
- `.zprofile` — macOS の path_helper 対策（`.zshenv` を再 source）
- `.zshrc` — インタラクティブ設定（プラグイン、補完、エイリアス、キーバインド）

## テーマ

catppuccin-mocha で統一（Ghostty, Starship, Vim, lightline）、glow は tokyo-night

## Git

- `~/.gitconfig.local` に個人情報（name, email）を分離（リポジトリに含めない）
- `~/.gitignore_global` でグローバル除外
- push.autoSetupRemote = true, pull.rebase = true
- rebase.autoSquash / autoStash = true
- branch.sort = -committerdate（最近使ったブランチを優先）
- merge.conflictstyle = zdiff3, rerere.enabled = true
- diff.algorithm = histogram, fetch.prune = true
- エイリアス: `vlog`（グラフ付きログ）

## fzf キーバインド

- `Ctrl+T` — ファイル検索（fd + bat プレビュー）
- `Ctrl+R` — コマンド履歴検索
- `Alt+C` — ディレクトリ移動（fd + eza プレビュー）
- `Ctrl+G` — git add 対象を選択（差分プレビュー付き）
- `Ctrl+S` — SSH 先を選択
- `Ctrl+]` — ghq リポジトリを選択して cd

## 初期セットアップ

- `~/.gitconfig.local` / `~/.gitignore_global` はリポジトリ直下の `*.example` から install.sh が初期化する（未存在時のみ）
- Claude Code は install.sh が native install で導入する（公式推奨、バックグラウンド自動更新あり）。Brewfile には含めない

## ルール

- 不要になったツール・設定は残さず削除する
- Homebrew の eval は使わず直接展開する（速度優先）
- mise の eval も使わず shims PATH で対応する
- `typeset -U path` で PATH 重複を排除する
- zoxide / starship は `~/.cache/zsh/` にキャッシュし、バイナリ更新時に自動再生成
- fzf は fd（ファイル検索）・bat（プレビュー）と連携（.zshrc で設定済み）
- Brewfile と実機の差分は `brew leaves` / `brew list --cask` で定期的に棚卸しする
