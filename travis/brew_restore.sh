#!/bin/sh
set -eux

if [ -f cache/brew-cache.tar.gz ]; then
    tar zxf cache/brew-cache.tar.gz --directory /usr/local/Cellar
    brew link wine libpng freetype jpeg libtool libusb libusb-compat fontconfig libtiff webp gd libgphoto2 little-cms2 cmake jasper libicns makedepend openssl net-snmp sane-backends libtasn1 gmp nettle gnutls makensis
fi
