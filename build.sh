#!/bin/sh
set -eux
cd `dirname $0`

VERSION=$(git describe --tags)

# start build for chrome
grunt build-chrome
grunt compress

# start build for electron
grunt build-electron
npm run build
cd release/electron
zip -j darwin-x64-${VERSION}.zip RedmineTimeTracker-darwin-x64-setup/RedmineTimeTracker.dmg
zip -j win32-ia32-${VERSION}.zip "RedmineTimeTracker-win32-ia32-setup/RedmineTimeTracker Setup.exe"
zip -j win32-x64-${VERSION}.zip  "RedmineTimeTracker-win32-x64-setup/RedmineTimeTracker Setup.exe"
cd -
