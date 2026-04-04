# ============================================================
# 1. Zinit
# ============================================================
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
  print -P "%F{33}▓▒░ Installing Zinit…%f"
  command mkdir -p "$(dirname $ZINIT_HOME)"
  command git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME" && \
    print -P "%F{34}▓▒░ Done.%f" || print -P "%F{160}▓▒░ Failed.%f"
fi
source "${ZINIT_HOME}/zinit.zsh"

# ============================================================
# 2. Exports
# ============================================================
export MANPAGER="less -X"
export EDITOR="vim"
export CLICOLOR=1

# ============================================================
# 3. Options
# ============================================================
# Basics
setopt no_beep
setopt interactive_comments

# Changing Directories
setopt auto_cd
setopt cdablevars
setopt pushd_ignore_dups

# Expansion and Globbing
setopt extended_glob

# Keybinding
setopt noflowcontrol

# History (share_history implies append/inc_append)
setopt extended_history
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_find_no_dups
setopt hist_reduce_blanks
setopt hist_verify

# Completion
setopt always_to_end
setopt auto_menu
setopt auto_name_dirs
setopt complete_in_word
setopt magic_equal_subst
setopt auto_param_slash
unsetopt menu_complete

# Prompt
setopt prompt_subst
setopt transient_rprompt

# Scripts and Functions
setopt multios

# ============================================================
# 4. History
# ============================================================
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history

# ============================================================
# 5. Completion
# ============================================================
autoload -Uz compinit
# compinit を24時間キャッシュ
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

bindkey '^[[Z' reverse-menu-complete

# ============================================================
# 6. Zinit Plugins (Turbo Mode)
# ============================================================
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start; bindkey '^ ' autosuggest-accept" \
    zsh-users/zsh-autosuggestions \
  blockf atpull"zinit creinstall -q ." \
    zsh-users/zsh-completions

# ============================================================
# 7. fzf
# ============================================================
source <(fzf --zsh)

# Ctrl+G: git add 対象を fzf で選択（差分プレビュー付き）
function fzf-git-add() {
  local selected=$(git status --porcelain | \
    fzf --multi --preview 'git diff --color=always {2}' | \
    awk '{print $NF}')
  if [[ -n "$selected" ]]; then
    BUFFER="git add $(echo "$selected" | tr '\n' ' ')"
    CURSOR=$#BUFFER
  fi
  zle accept-line
}
zle -N fzf-git-add
bindkey '^g' fzf-git-add

# Ctrl+S: ssh (fzf で選択)
function fzf-ssh() {
  local res=$(grep "^Host " ~/.ssh/config | grep -v '*' | cut -b 6- | fzf)
  if [[ -n "$res" ]]; then
    BUFFER="ssh $res"
    zle accept-line
  fi
  zle clear-screen
}
zle -N fzf-ssh
bindkey '^S' fzf-ssh

# Ctrl+]: ghq リポジトリ (fzf で選択)
function fzf-src() {
  local selected=$(ghq list --full-path | fzf --preview 'eza -la --icons --git {}')
  if [[ -n "$selected" ]]; then
    BUFFER="cd ${selected}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N fzf-src
bindkey '^]' fzf-src

# ============================================================
# 8. zoxide
# ============================================================
eval "$(zoxide init zsh)"

# ============================================================
# 9. Aliases
# ============================================================
if [[ -f "${HOME}/.zsh-alias" ]]; then
  source "${HOME}/.zsh-alias"
fi

# ============================================================
# 10. External completions
# ============================================================
# gcloud
if [[ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]]; then
  source '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'
fi

# bun
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"


# ============================================================
# 11. Starship (must be last)
# ============================================================
eval "$(starship init zsh)"
