#!/bin/sh

FILELIST='
.atom
.config
.vim
.zsh.d
.gitconfig
.gitignore
.vimrc
.zshrc
.zshenv
.tmux.conf
'

if [! -d ~/.dotfiles/.vim ];
  then
    mkdir ~/.dotfiles/.vim
fi

# create local settig file
cd ~
touch ~/.vimrc.local
touch ~/.gitconfig.local

# stash old file
if [ ! -e ~/old_files ]; then
    mkdir ~/old_files
    for FILE in ${FILELIST};
    do
        [ -e ~/${FILE} ] && mv ~/${FILE} ~/old_files/
    done
fi

# create symboliclink
for FILE in ${FILELIST};
do
    rm -rf ~/${FILE}
    ln -fis ~/.dotfiles/${FILE} ~/${FILE}
done


# submodule update
# ----------------------------------------------------------------------
cd ~/.dotfiles
git submodule update --init --recursive
cd - > /dev/null

# NeoBundleinstall
mkdir -p ~/.vim/bundle
git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
vim +NeoBundleInstall! +qall
