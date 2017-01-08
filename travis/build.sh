#!/bin/sh
set -eux
cd `dirname $0`

# start build for chrome
grunt build-chrome
grunt compress:ci

# start build for electron
grunt build-electron
npm run clean
npm run build:osx
cd release/electron
zip -j darwin-x64.zip "RedmineTimeTracker-darwin-x64-setup/RedmineTimeTracker.dmg"
cd -
