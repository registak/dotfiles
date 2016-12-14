# --------------------------------
# ----------- nodebrew -----------
# --------------------------------
if [ -d ${HOME}/.nodebrew  ] ; then
    export PATH=${HOME}/.nodebrew/current/bin:$PATH
fi

# --------------------------------
# -------------- go --------------
# --------------------------------
export GOROOT=/usr/local/opt/go/libexec
export GOPATH=${HOME}/golang
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

# --------------------------------
# ------------homebrecask---------
# --------------------------------
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
