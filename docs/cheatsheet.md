# チートシート

dotfiles で設定しているキーバインド・エイリアス・カスタム設定の逆引きリファレンス。

---

## Ghostty（ターミナル）

| キー | 動作 |
|------|------|
| `` Cmd+` `` | Quick Terminal（画面上部からトグル） |
| `Cmd+T` | 新しいタブ |
| `Cmd+W` | タブ/ペインを閉じる |
| `Cmd+Shift+Enter` | 右に分割 |
| `Cmd+Shift+-` | 下に分割 |
| `Cmd+Alt+←→↑↓` | ペイン間移動 |

---

## シェル（zsh）

### fzf 連携

| キー | 動作 | 設定元 |
|------|------|--------|
| `Ctrl+T` | ファイル検索（fd + bat プレビュー） | fzf 組み込み |
| `Ctrl+R` | コマンド履歴検索 | fzf 組み込み |
| `Alt+C` | ディレクトリ移動（fd + eza プレビュー） | fzf 組み込み |
| `Ctrl+G` | git add 対象を選択（差分プレビュー付き） | .zshrc カスタム |
| `Ctrl+S` | SSH 先を選択（~/.ssh/config から） | .zshrc カスタム |
| `Ctrl+]` | ghq リポジトリを選択して cd | .zshrc カスタム |

### 補完

| キー | 動作 |
|------|------|
| `Tab` | 補完（メニュー選択） |
| `Shift+Tab` | 補完を逆方向に移動 |
| `Ctrl+Space` | autosuggestions を確定 |

### ナビゲーション

| コマンド | 動作 |
|----------|------|
| `z <keyword>` | zoxide でディレクトリにジャンプ |
| `zi` | zoxide + fzf で対話的に選択 |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |

### zsh の便利設定

| 設定 | 効果 |
|------|------|
| `auto_cd` | ディレクトリ名だけで cd（`~/projects` → `cd ~/projects`） |
| `extended_glob` | 高度なグロブ（`**/*.ts` 等） |
| `hist_ignore_space` | スペースで始めたコマンドは履歴に残さない |
| `share_history` | 全ターミナルで履歴を共有 |
| `hist_verify` | `!!` 等の履歴展開を実行前に確認 |

---

## エイリアス

### ファイル操作

| エイリアス | 展開先 |
|-----------|--------|
| `ls` | `eza -a --icons` |
| `ll` | `eza -la --icons --git` |
| `lt` | `eza -la --icons --git --tree --level=2` |
| `cp` | `cp -i`（上書き確認） |
| `mv` | `mv -i`（上書き確認） |
| `mkd` | `mkdir -p` |

### Git

| エイリアス | 展開先 |
|-----------|--------|
| `gs` | `git status --short --branch` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gd` | `git diff` |
| `gl` | `git log --oneline --graph -20` |
| `gco` | `git checkout` |
| `gb` | `git branch` |

### その他

| エイリアス | 展開先 |
|-----------|--------|
| `vi` | `vim` |
| `_` | `sudo` |
| `reload` | `source ~/.zshrc` |
| `myip` | `curl -s ifconfig.me` |
| `ports` | `lsof -i -P -n \| grep LISTEN` |

### サフィックスエイリアス

拡張子に応じてコマンドが自動選択される。

| 拡張子 | 動作 |
|--------|------|
| `.py` | `python` で実行 |
| `.png` `.jpg` `.jpeg` `.gif` | `open` で表示 |
| `.html` | Google Chrome で開く |

---

## Vim

### 基本

| キー | 動作 |
|------|------|
| `Space` | Leader キー |
| `Esc Esc` | 検索ハイライト解除 |

### fzf 連携

| キー | 動作 |
|------|------|
| `Space f` | `:Files` — ファイル検索 |
| `Space b` | `:Buffers` — バッファ一覧 |
| `Space h` | `:History` — 最近開いたファイル |

### ウィンドウ操作

| キー | 動作 |
|------|------|
| `Ctrl+h` | 左のウィンドウへ |
| `Ctrl+j` | 下のウィンドウへ |
| `Ctrl+k` | 上のウィンドウへ |
| `Ctrl+l` | 右のウィンドウへ |

### プラグイン

| プラグイン | 用途 |
|-----------|------|
| vim-surround | 囲み文字の操作（`cs"'` で `"` → `'`） |
| vim-commentary | コメントトグル（`gcc` で行コメント） |
| vim-fugitive | Git 操作（`:Git blame`, `:Git diff`） |
| vim-gitgutter | 変更行をサインカラムに表示 |

---

## Git カスタム設定

### エイリアス

| コマンド | 動作 |
|----------|------|
| `git vlog` | `git log --graph --oneline --decorate -20` |

### 知っておくと便利な設定

| 設定 | 効果 |
|------|------|
| `push.autoSetupRemote` | 初回 push で自動的にリモート追跡を設定 |
| `pull.rebase` | pull 時に merge ではなく rebase |
| `rebase.autoSquash` | `fixup!` / `squash!` コミットを自動並べ替え |
| `rebase.autoStash` | rebase 前に自動 stash、完了後に自動 pop |
| `fetch.prune` | fetch 時に削除済みリモートブランチを自動削除 |
| `diff.algorithm = histogram` | より賢い diff 表示 |
| `merge.conflictstyle = zdiff3` | コンフリクト表示に共通祖先を含める |
| `rerere.enabled` | コンフリクト解決を記録し、同じ解決を自動適用 |
| `branch.sort = -committerdate` | `git branch` を最近使った順に表示 |

---

## dotfiles 管理

| コマンド | 動作 |
|----------|------|
| `make install` | install.sh をフル実行 |
| `make stow` | シンボリックリンクを更新 |
| `make brew` | Brewfile を反映 |
| `make mise-install` | mise ツールをインストール |
| `rm -rf ~/.cache/zsh/` | zoxide/starship のキャッシュをリセット |
