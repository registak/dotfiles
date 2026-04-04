# Ghostty 設定ガイド

macOS / Linux 向けの GPU アクセラレーテッド・ターミナルエミュレータ。軽量で高速、設定はテキストファイル1つで完結する。

設定ファイル: `~/.config/ghostty/config`（実体は `.dotfiles/ghostty/.config/ghostty/config`）

---

## 基本の仕組み

- 設定は `key = value` 形式のプレーンテキスト
- TOML でも YAML でもない独自フォーマット（シンプル）
- 設定変更後は Ghostty を再起動するか `Cmd+Shift+,` でリロード

---

## 各セクションの解説

### Font — フォント設定

```
font-family = "JetBrainsMono Nerd Font"
font-family-bold = "JetBrainsMono Nerd Font"
font-family-italic = "JetBrainsMono Nerd Font"
font-size = 14
font-feature = "calt"
font-feature = "liga"
adjust-cell-height = 25%
```

| 設定 | 意味 |
|------|------|
| `font-family` | 使用フォント（[Nerd Font](https://www.nerdfonts.com/) 推奨） |
| `font-family-bold` / `italic` | 太字・斜体のフォント（未指定だと OS が自動選択） |
| `font-feature = "calt"` | コンテキスト依存の合字（contextual alternates） |
| `font-feature = "liga"` | プログラミング合字（`!=` → `≠`, `=>` → `⇒` 等） |
| `adjust-cell-height = 25%` | 行間を 25% 広げる（読みやすさ向上） |

**行間の調整**: `adjust-cell-height` は `15%`（コンパクト）〜 `30%`（ゆったり）がおすすめ。好みに合わせて変更する。

### Theme — テーマ

```
theme = "catppuccin-mocha"
```

Ghostty には多数のビルトインテーマが含まれている。

```bash
# 使えるテーマ一覧を見る
ghostty +list-themes

# 人気テーマ例
# catppuccin-mocha, catppuccin-latte, dracula, tokyo-night,
# gruvbox-dark, nord, one-dark, solarized-dark
```

### Window — ウィンドウ設定

```
window-padding-x = 8
window-padding-y = 4
window-padding-balance = true
window-decoration = true
window-save-state = always
```

| 設定 | 意味 |
|------|------|
| `window-padding-x` / `y` | テキストと枠の間の余白（ピクセル） |
| `window-padding-balance` | リサイズ時にパディングを左右均等に自動調整 |
| `window-decoration` | ウィンドウの枠・ボタンを表示する |
| `window-save-state = always` | 再起動時にウィンドウの位置・サイズ・タブを復元 |

### macOS — macOS 固有設定

```
macos-option-as-alt = true
macos-titlebar-style = hidden
```

| 設定 | 意味 |
|------|------|
| `macos-option-as-alt` | Option キーを Alt として使えるようにする（シェルのキーバインドに必須） |
| `macos-titlebar-style = hidden` | タイトルバーを非表示にしてすっきりした見た目にする |

### Cursor — カーソル設定

```
cursor-style = bar
cursor-style-blink = false
```

| 値 | 見た目 |
|-----|--------|
| `bar` | `│` 細い縦線（現在の設定） |
| `block` | `█` 四角ブロック |
| `underline` | `_` 下線 |

`cursor-style-blink = false` で点滅を無効化。集中しやすくなる。

### Clipboard — クリップボード

```
copy-on-select = clipboard
clipboard-read = ask
clipboard-paste-protection = true
```

| 設定 | 意味 |
|------|------|
| `copy-on-select` | テキストを選択するだけで自動コピー |
| `clipboard-read = ask` | プログラムがクリップボードを読もうとしたら確認ダイアログを表示 |
| `clipboard-paste-protection` | 改行を含むペースト（意図しないコマンド実行）を警告 |

**セキュリティ Tips**: `clipboard-paste-protection` は、Web からコピーしたテキストに隠れた改行やコマンドが含まれている場合に保護してくれる。

### Scrollback — スクロールバック

```
scrollback-limit = 10000
```

ターミナルの出力履歴をどこまで遡れるかの設定。ログを大量に流す作業では多めに設定すると便利。

### Quick Terminal — ドロップダウンターミナル

```
keybind = global:super+grave_accent=toggle_quick_terminal
quick-terminal-position = top
quick-terminal-animation-duration = 0.15
```

**どんなアプリを使っていても** `` Cmd+` `` を押すと、画面上部からターミナルがスライドダウンする。もう一度押すと隠れる。

| 設定 | 意味 |
|------|------|
| `global:super+grave_accent` | グローバルホットキー `` Cmd+` `` |
| `quick-terminal-position = top` | 画面上部から表示（`bottom`, `left`, `right` も可） |
| `quick-terminal-animation-duration` | アニメーション速度（秒）。0 で即時表示 |

### Keybinds — キーバインド

```
keybind = super+t=new_tab
keybind = super+w=close_surface
keybind = super+shift+enter=new_split:right
keybind = super+shift+minus=new_split:down
keybind = super+alt+left=goto_split:left
keybind = super+alt+right=goto_split:right
keybind = super+alt+up=goto_split:top
keybind = super+alt+down=goto_split:bottom
```

#### タブ操作

| キー | 動作 |
|------|------|
| `Cmd+T` | 新しいタブを開く |
| `Cmd+W` | 現在のタブ/ペインを閉じる |

#### Split（画面分割）

tmux なしでターミナルを分割できる。

| キー | 動作 |
|------|------|
| `Cmd+Shift+Enter` | 右に分割 |
| `Cmd+Shift+-` | 下に分割 |
| `Cmd+Alt+←` | 左のペインに移動 |
| `Cmd+Alt+→` | 右のペインに移動 |
| `Cmd+Alt+↑` | 上のペインに移動 |
| `Cmd+Alt+↓` | 下のペインに移動 |

```
Split のイメージ:

┌──────────┬──────────┐
│          │          │  ← Cmd+Shift+Enter で右に分割
│  ペイン1  │  ペイン2  │
│          │          │
├──────────┴──────────┤
│                     │  ← Cmd+Shift+- で下に分割
│      ペイン3         │
│                     │
└─────────────────────┘

Cmd+Alt+矢印 でペイン間を移動
```

### Misc — その他

```
confirm-close-surface = false
mouse-hide-while-typing = true
```

| 設定 | 意味 |
|------|------|
| `confirm-close-surface = false` | タブ/ペインを閉じるときの確認を省略 |
| `mouse-hide-while-typing` | タイピング中にマウスカーソルを自動非表示 |

---

## よくある操作

### 設定の反映

Ghostty を再起動するか、設定ファイルを保存した後に:
- `Cmd+Shift+,` でリロード（一部の設定はリロードでは反映されない）

### テーマのプレビュー

```bash
ghostty +list-themes
```

### フォントの確認

```bash
# インストール済みフォントの検索
ghostty +list-fonts | grep -i "jetbrains"
```

### 公式ドキュメント

- 設定リファレンス: https://ghostty.org/docs/config/reference
- キーバインド: https://ghostty.org/docs/config/keybind
