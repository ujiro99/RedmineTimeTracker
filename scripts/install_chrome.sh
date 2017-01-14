#!/bin/bash
set -ev

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    brew update
    brew cask install google-chrome
else
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome*.deb
    sh -e /etc/init.d/xvfb start
fi
