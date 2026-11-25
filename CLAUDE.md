# dotfiles

macOS (Apple Silicon) 向けの個人 dotfiles。mise bootstrap でシンボリックリンクとセットアップを管理。

## mise bootstrap

`mise/.config/mise/config.toml` がグローバル設定を兼ねる。

- `[bootstrap] dotfile_groups` — `~` へファイル単位でリンクするディレクトリ
- `[tasks.bootstrap]` — ローカル設定の雛形、Claude Code、VS Code 拡張の導入。毎回実行されるので、何度実行しても同じ結果になるように書く
- `[tools]` — ランタイム。バージョンは `mise.lock` で固定

```bash
mise bootstrap --dry-run   # 変更内容の確認
mise bootstrap             # リンク・ランタイム・bootstrap タスク
mise dotfiles apply        # リンクだけ更新
mise bootstrap status      # 状態の確認
```

新しいファイルを追加した場合は対応ディレクトリに配置して `mise dotfiles apply` を実行する。ディレクトリを増やした場合は `dotfile_groups` に追加する。

Homebrew のパッケージは Brewfile で管理し、`[bootstrap.packages]` は使わない。

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

## 初期セットアップ

- `~/.gitconfig.local` / `~/.gitignore_global` はリポジトリ直下の `*.example` から bootstrap タスクが初期化する（未存在時のみ）
- Claude Code は bootstrap タスクが native install で導入する（公式推奨、バックグラウンド自動更新あり）。Brewfile には含めない

## ルール

- 不要になったツール・設定は残さず削除する
- Homebrew の eval は使わず直接展開する（速度優先）
- mise の eval も使わず shims PATH で対応する。`[bootstrap.mise_shell_activate]` は eval を書き込むので設定しない
- `typeset -U path` で PATH 重複を排除する
- zoxide / starship は `~/.cache/zsh/` にキャッシュし、バイナリ更新時に自動再生成
- fzf は fd（ファイル検索）・bat（プレビュー）と連携（.zshrc で設定済み）
- Brewfile と実機の差分は `brew leaves` / `brew list --cask` で定期的に棚卸しする
