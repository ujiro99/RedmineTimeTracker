#!/bin/sh
set -eux
cd `dirname $0`

# start build for chrome
grunt build-chrome
grunt compress:ci

# start build for electron
grunt build-electron
npm run build
cd release/electron
zip -j darwin-x64.zip "RedmineTimeTracker-darwin-x64-setup/RedmineTimeTracker.dmg"
zip -j win32-ia32.zip "RedmineTimeTracker-win32-ia32-setup/RedmineTimeTracker Setup.exe"
zip -j win32-x64.zip  "RedmineTimeTracker-win32-x64-setup/RedmineTimeTracker Setup.exe"
cd -
