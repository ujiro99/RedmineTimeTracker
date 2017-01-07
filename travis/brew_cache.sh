#!/bin/sh
set -eux

mkdir cache
tar czf cache/brew-cache.tar.gz --directory /usr/local/Cellar wine libpng freetype jpeg libtool libusb libusb-compat fontconfig libtiff webp gd libgphoto2 little-cms2 cmake jasper libicns makedepend openssl net-snmp sane-backends libtasn1 gmp nettle gnutls makensis
