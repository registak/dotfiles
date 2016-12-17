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
export PATH=$PATH:/usr/local/opt/go/libexec/bin

# --------------------------------
# -------------- pyenv --------------
# --------------------------------
if which pyenv > /dev/null; then
  eval "$(pyenv init -)";
  eval "$(pyenv virtualenv-init -)"
fi
