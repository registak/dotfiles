# Starship 設定ガイド

シェルプロンプトをカスタマイズするツール。ターミナルに表示される情報と見た目を自由に変えられる。

設定ファイル: `~/.config/starship.toml`（実体は `.dotfiles/starship/.config/starship.toml`）

---

## プロンプトの見え方

```
                                                      3s  22.14.0 12:30PM
~/.dotfiles on main ⇡1 !2
❯ _
```

| 位置 | 表示内容 |
|------|---------|
| 左上 | ディレクトリ + git ブランチ + git status |
| 右上 | コマンド実行時間 + Node.js バージョン + 時刻 |
| 左下 | 入力カーソル（成功=紫 `❯`、エラー=赤 `❯`） |

---

## テーマ

[Catppuccin Mocha](https://github.com/catppuccin/catppuccin) パレットを使用。設定ファイル内で色名（`peach`, `mauve`, `lavender` 等）をそのまま使える。

```toml
palette = "catppuccin_mocha"

# 使用例
[character]
success_symbol = "[❯](lavender)"   # lavender = #b4befe
```

---

## 各モジュールの解説

### directory — ディレクトリ表示

```toml
[directory]
style = "bold peach"
truncation_length = 3          # 最大3階層まで表示
truncate_to_repo = true        # git リポジトリ内ではルートから表示
repo_root_style = "bold peach"
repo_root_format = "[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style) "
```

| 設定 | 意味 | 例 |
|------|------|-----|
| `truncation_length = 3` | 深いパスを省略 | `~/a/b/c/d` → `b/c/d` |
| `truncate_to_repo = true` | git リポジトリ内ではルートから表示 | `.dotfiles/docs` |
| `repo_root_format` | リポジトリ名を太字で強調表示 | **dotfiles**/docs |

### git_branch — ブランチ名

```toml
[git_branch]
format = "on [$branch]($style) "
style = "bold blue"
```

`on main` のように表示される。

### git_status — 変更状態

```toml
[git_status]
format = '([$all_status$ahead_behind]($style) )'
style = "mauve"
conflicted = "="               # コンフリクトあり
ahead = "⇡${count}"           # リモートより進んでいる
behind = "⇣${count}"          # リモートより遅れている
diverged = "⇕⇡${ahead_count}⇣${behind_count}"  # 分岐
untracked = "?${count}"       # 未追跡ファイル
stashed = "📦"                 # stash あり
modified = "!${count}"        # 変更あり
staged = "+${count}"          # ステージ済み
deleted = "✘${count}"         # 削除済み
```

表示例:

| 状態 | 表示 | 意味 |
|------|------|------|
| ファイルを編集した | `!2` | 2ファイル変更あり |
| `git add` した | `+1` | 1ファイルステージ済み |
| 新規ファイルがある | `?3` | 3ファイル未追跡 |
| push していない | `⇡1` | 1コミット先行 |
| pull していない | `⇣2` | 2コミット遅れ |
| 複合 | `+1 !2 ?1 ⇡1` | まとめて表示 |

### character — 入力プロンプト

```toml
[character]
success_symbol = "[❯](lavender)"   # 前のコマンドが成功 → 紫
error_symbol = "[❯](red)"          # 前のコマンドが失敗 → 赤
```

コマンドの終了コードで色が変わるので、エラーに気づきやすい。

### cmd_duration — コマンド実行時間（右プロンプト）

```toml
[cmd_duration]
min_time = 2_000               # 2秒以上かかったら表示
format = "[$duration]($style) "
style = "yellow"
show_notifications = true      # デスクトップ通知を有効化
min_time_to_notify = 30_000    # 30秒以上で通知
```

- `sleep 3` → `3s` と右側に表示
- `npm install` に30秒以上かかった → macOS の通知センターに通知

### nodejs — Node.js バージョン（右プロンプト）

```toml
[nodejs]
format = "[$symbol($version)]($style) "
symbol = " "                  # Nerd Font アイコン
style = "green"
detect_files = ["package.json"]  # package.json があるときだけ表示
```

`package.json` があるディレクトリに入ると自動でバージョンが表示される。

### python — Python バージョン（右プロンプト）

```toml
[python]
format = '[${symbol}${pyenv_prefix}(${version} )(\($virtualenv\) )]($style)'
symbol = " "
style = "yellow"
```

Python プロジェクト（`requirements.txt`, `pyproject.toml` 等）のディレクトリで表示。仮想環境名も表示される。

### time — 現在時刻（右プロンプト）

```toml
[time]
disabled = false               # デフォルトは無効なので明示的に有効化
format = '[$time]($style)'
style = "dimmed white"
time_format = "%l:%M%p"       # 12時間表記（例: 1:30PM）
```

---

## よくあるカスタマイズ

### 表示モジュールを増やす/減らす

`format`（左）と `right_format`（右）で制御する。

```toml
# 左プロンプト
format = """
$directory\
$git_branch\
$git_status\
$character"""

# 右プロンプト
right_format = """
$cmd_duration\
$nodejs\
$python\
$time"""
```

モジュールを追加するには `$モジュール名\` を追記する。削除するには行を消す。

### プロンプト前の空行

```toml
add_newline = true    # コマンド出力とプロンプトの間に空行を入れる
```

### 設定の反映

```bash
# 設定ファイルを保存するだけで次のプロンプト描画から即反映
# ターミナルの再起動は不要（Enter を押すだけでOK）
```

### 公式ドキュメント

- 全モジュール一覧: https://starship.rs/config/
- プリセット: https://starship.rs/presets/
