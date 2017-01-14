#!/bin/sh
set -eux

#このシェルスクリプトを実行した場所をカレントディレクトリにする
cd `dirname $0`

resdir="../build"
appdir="../app"

# 出力ディレクトリの生成
icondir="${resdir}/icon.iconset"
mkdir -p ${icondir}

# 変換元ファイル
BASE_FILE="${resdir}/icon_1024x1024.png"

#----------------------------------------------------------------------
#  1. icon_512x512@2x.png (1024px)
#  2. icon_512x512.png
#  3. icon_256x256@2x.png (512px, 2と同じ画像サイズ)
#  4. icon_256x256.png
#  5. icon_128x128@2x.png (256px, 4と同じ画像サイズ)
#  6. icon_128x128.png
#  7. icon_32x32@2x.png (64px)
#  8. icon_32x32.png
#  9. icon_16x16@2x.png (32px, 8と同じ画像サイズ)
# 10. icon_16x16.png
#----------------------------------------------------------------------

# resize png file
# @param $1 - Output file name.
# @param $2 - Resample size [px].
resize_png () {
    if [ -e "${icondir}/$1.png" ]; then
        echo "$1.png はすでに存在しています。処理をスキップします。"
    else
        sips -Z $2 ${BASE_FILE} --out ${icondir}/$1.png
    fi
}

# copy png file
# @param $1 - Output file name.
# @param $2 - File name of copy source.
copy_png () {
    if [ -e "${icondir}/$1.png" ]; then
        echo "$1.png はすでに存在しています。処理をスキップします。"
    else
        cp $2 ${icondir}/$1.png
    fi
}

#----------------------------------------------------------------------
# Start resize.
#----------------------------------------------------------------------

if [ -e ${BASE_FILE} ]; then
    echo "${BASE_FILE} をもとに画像を生成します。"
else
    echo "${BASE_FILE} がありません。"
    return 2> /dev/null
    exit
fi

#  1. icon_512x512@2x.png (1024px)
copy_png icon_512x512@2x ${BASE_FILE}

#  2. icon_512x512.png
resize_png icon_512x512 512

#  3. icon_256x256@2x.png (512px, 2と同じ画像サイズ)
copy_png icon_256x256@2x ${icondir}/icon_512x512.png

#  4. icon_256x256.png
resize_png icon_256x256 256

#  5. icon_128x128@2x.png (256px, 4と同じ画像サイズ)
copy_png icon_128x128@2x ${icondir}/icon_256x256.png

#  6. icon_128x128.png
resize_png icon_128x128 128

#  7. icon_32x32@2x.png (64px)
resize_png icon_32x32@2x 64

#  8. icon_32x32.png
resize_png icon_32x32 32

#  9. icon_16x16@2x.png (32px, 8と同じ画像サイズ)
copy_png icon_16x16@2x ${icondir}/icon_32x32.png

# 10. icon_16x16.png
resize_png icon_16x16 16

#----------------------------------------------------------------------
# Generate icon files.
#----------------------------------------------------------------------

# create icns (mac)
iconutil -c icns ${icondir} --output ${resdir}/icon.icns

# create ico (windows)
convert ${BASE_FILE} -define icon:auto-resize ${resdir}/icon.ico

# for chrome app
rm ${appdir}/images/icon_128.png
cp ${icondir}/icon_128x128.png ${appdir}/images/icon_128.png
rm ${appdir}/images/icon_notification.png
cp ${icondir}/icon_128x128.png ${appdir}/images/icon_notification.png

# create gray scale icon (for develop)
rm ${appdir}/images/icon_128_gray.png
convert ${icondir}/icon_128x128.png -colorspace Gray ${appdir}/images/icon_128_gray.png

