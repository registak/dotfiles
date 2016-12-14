#!/bin/sh
#
# install homebrew and formula 
#

if test ! $(which brew)
    then
    echo "Installing homebrew.."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
# Ensure the latest versions
brew update
brew upgrade

# Install cask
brew install caskroom/cask/brew-cask
# Install OSX system requirements
brew cask install xquartz


# homebrew formula
brew install zsh

brew install git
brew install tree
brew install ctags
brew install jq

brew install memcached
brew install mongodb
brew install redis

brew install python
brew install rbenv
brew install ruby-build

# Clean up
brew linkapps
brew cleanup
brew prune
brew cask cleanup

