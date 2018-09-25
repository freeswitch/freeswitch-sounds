#!/bin/sh
name=`awk 'NR==1{v=gsub(/(\(|\)|-.+)/, "", $2);print $1"_"$v;}' ./debian/changelog`
tar --exclude='./.git' --exclude='./debian' -Jncvf ../${name}.orig.tar.xz .
