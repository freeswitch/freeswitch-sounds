#!/bin/bash

current_dir=${PWD}
sound_set=$1
mkdir -p ../${sound_set}
cp -R debian ../${sound_set}
cd ../${sound_set}
ls -la
./debian/bootstrap.sh -p ${sound_set}
./debian/rules get-orig-source
tar -xv --strip-components=1 -f *_*.orig.tar.xz && mv *_*.orig.tar.xz ../
dpkg-buildpackage -uc -us -sa -Zxz -z9
cd ..
rm -rf ${sound_set}
cd ${current_dir}
ls -la ../