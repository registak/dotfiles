export LANG=ja_JP.UTF-8
typeset -U path

# Homebrew (eval 不要、直接展開で高速)
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

# mise (shims PATH のみ、eval 不要)
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Google Cloud SDK
[ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ] && \
  . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# local bin
export PATH="$HOME/.local/bin:$PATH"
