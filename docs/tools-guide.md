# モダン CLI ツールガイド

dotfiles で使っているツールの使い方まとめ。

---

## eza — ls の代替

ファイル一覧を色付き・アイコン付きで表示する。

```bash
# 基本（エイリアス設定済み）
ls          # eza -a --icons（隠しファイル含む）
ll          # eza -la --icons --git（詳細 + git status 表示）
lt          # eza -la --icons --git --tree --level=2（ツリー表示）

# 直接使う場合
eza                     # カレントディレクトリ
eza -la                 # 詳細表示
eza --tree --level=3    # 3階層のツリー
eza --sort=modified     # 更新日順
```

---

## fzf — あいまい検索

リストから対話的に絞り込み選択するツール。パイプで何でも検索できる。

### キーバインド（.zshrc で設定済み）

| キー | 動作 |
|------|------|
| `Ctrl+R` | コマンド履歴を検索（fzf 組み込み） |
| `Ctrl+G` | git add するファイルを選択（差分プレビュー付き） |
| `Ctrl+S` | SSH 先を選択して接続 |
| `Ctrl+]` | ghq リポジトリを選択して cd |

### 単体で使う

```bash
# ファイルを検索して開く
vim $(fzf)

# コマンドの出力を絞り込む
ps aux | fzf
git branch | fzf

# プレビュー付き
fzf --preview 'cat {}'

# 複数選択（Tab で選択、Enter で確定）
git status -s | fzf --multi
```

### fzf の操作

| キー | 動作 |
|------|------|
| 文字入力 | 絞り込み |
| `↑` / `↓` | カーソル移動 |
| `Enter` | 選択確定 |
| `Tab` | 複数選択（--multi 時） |
| `Ctrl+C` / `Esc` | キャンセル |

---

## mise — ランタイムバージョン管理

Node.js, Python, Ruby 等のバージョンを管理する。anyenv/nodenv/pyenv の代替。

```bash
# インストール済みのツール一覧
mise list

# 使えるバージョンを検索
mise ls-remote node
mise ls-remote python

# バージョンをインストール
mise install node@22
mise install python@3.13

# プロジェクトで使うバージョンを指定（.mise.toml が作られる）
mise use node@22
mise use python@3.13

# グローバルのデフォルトを設定
mise use --global node@22

# 現在のバージョン確認
mise current
node -v
python3 --version
```

### 仕組み
- `.zshenv` で `~/.local/share/mise/shims` に PATH を通している
- プロジェクトに `.mise.toml` があれば自動でバージョンが切り替わる
- `eval "$(mise activate zsh)"` 不要（shims 方式で高速）

---

## starship — プロンプト

シェルプロンプトをカスタマイズするツール。設定は `~/.config/starship.toml`。

詳細は [starship-guide.md](./starship-guide.md) を参照。

```
~/.dotfiles on main ⇡1 !2      ← 左: ディレクトリ + git ブランチ + status
                 3s  22.14.0 12:30PM  ← 右: 実行時間 + node ver + 時刻
❯                                ← 入力行（成功=紫、エラー=赤）
```

---

## zoxide — cd の代替

一度行ったディレクトリを覚えて、部分一致でジャンプできる。

```bash
# 基本（cd の代わりに z を使う）
z dotfiles          # ~/.dotfiles に移動（過去に行ったことがあれば）
z proj myapp        # ~/projects/myapp に移動（複数キーワードOK）

# 対話的に選択（fzf 連携）
zi                  # 候補一覧から fzf で選ぶ

# 通常の cd も使える
cd ~/somewhere      # 普通の cd はそのまま動く
```

### 仕組み
- `cd` や `z` で移動するたびにディレクトリを記録
- 頻度と最近使ったかでスコアリング
- 最もスコアの高いディレクトリにジャンプ

### tips
- 最初は学習データがないので `cd` で移動する必要がある
- 使い続けるほど賢くなる
- `z -` で直前のディレクトリに戻る

---

## stow — dotfiles のシンボリックリンク管理

ディレクトリ構造をそのままホームディレクトリに展開（symlink）するツール。

### 今の使い方

```bash
cd ~/.dotfiles

# 全パッケージの symlink を作成（install.sh がやっていること）
stow -t ~ zsh git vim starship ghostty mise

# 特定のパッケージだけ
stow -t ~ zsh

# symlink を削除
stow -t ~ -D zsh

# 再作成（削除 → 作成）
stow -t ~ -R zsh

# 何が起きるか確認（dry-run）
stow -t ~ -n -v zsh
```

### 新しい設定を追加するとき

```bash
# 例: ~/.config/wezterm/wezterm.lua を管理したい場合

# 1. パッケージディレクトリを作る（ホームからの相対パスを再現）
mkdir -p ~/.dotfiles/wezterm/.config/wezterm

# 2. 設定ファイルを移動
mv ~/.config/wezterm/wezterm.lua ~/.dotfiles/wezterm/.config/wezterm/

# 3. stow で symlink 作成
cd ~/.dotfiles
stow -t ~ wezterm

# 4. install.sh にパッケージ名を追加
# stow -v -t "$HOME" zsh git vim starship ghostty wezterm
```

### 仕組み
```
.dotfiles/zsh/.zshrc  →  stow  →  ~/.zshrc (symlink)
.dotfiles/starship/.config/starship.toml  →  stow  →  ~/.config/starship.toml (symlink)
```
パッケージ内のディレクトリ構造がそのまま `~` に展開される。

---

## ghq — リポジトリ管理

Git リポジトリを一元管理する。`Ctrl+]` で fzf 連携して素早く移動できる。

```bash
# リポジトリを clone（~/ghq/ 以下に自動配置）
ghq get https://github.com/user/repo

# 短縮形
ghq get user/repo

# 管理中のリポジトリ一覧
ghq list

# fzf で選んで移動（Ctrl+] でも同じ）
cd $(ghq list --full-path | fzf)
```
