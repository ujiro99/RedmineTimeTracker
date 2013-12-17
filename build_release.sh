#!/bin/bash

OUT_DIR=./release

rm -rf ${OUT_DIR} ./css ./scripts ./views
git co -f
grunt production
rm scripts/script.js
mkdir ${OUT_DIR}
cp -r _locales ${OUT_DIR}
cp -r css ${OUT_DIR}
cp -r fonts ${OUT_DIR}
cp -r images ${OUT_DIR}
cp -r manifest.json ${OUT_DIR}
cp -r scripts ${OUT_DIR}
cp -r views ${OUT_DIR}
cd ${OUT_DIR}
zip -r package.zip .
