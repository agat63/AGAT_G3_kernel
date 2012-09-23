#!/bin/bash
make distclean
# Directory "extras" must be available in top kernel directory. Sign scripts must also be available at ~/.gnome2/nautilus-scripts/SignScripts/
# Edit CROSS_COMPILE to mirror local path. Edit "version" to any desired name or number but it cannot have spaces. 
pwd=`readlink -f .`
export CROSS_COMPILE=$pwd/kernel-extras/arm-eabi-4.4.3/bin/arm-eabi-
export ARCH=arm
<<<<<<< HEAD
export version=AGAT_GS3
=======
export version=agat
>>>>>>> 512857903638d37956fd40a24b4bb4fccf85ae82

# Determines the number of available logical processors and sets the work thread accordingly
export JOBS="(expr 4 + $(grep processor /proc/cpuinfo | wc -l))"

loc=~/.gnome2/nautilus-scripts/SignScripts/
date=$(date +%Y%m%d-%H:%M:%S)

# Check for a log directory in ~/ and create if its not there
[ -d ~/logs ] || mkdir -p ~/logs

# Setting up environment
rm out
mkdir -p out
cp -r kernel-extras/mkboot $pwd
cp -r kernel-extras/zip $pwd

# Build entire kernel and create build log
<<<<<<< HEAD
make agat_defconfig
make headers_install
# make modules
make -j5 2>&1 | tee ~/logs/$version.txt
=======
make m2_spr_defconfig
make headers_install
make modules
make -j8 zImage 2>&1 | tee ~/logs/$version.txt
>>>>>>> 512857903638d37956fd40a24b4bb4fccf85ae82

echo "making boot image"
cp arch/arm/boot/zImage mkboot/
cd mkboot
./img-l710-tw.sh
cd ..

echo "making signed zip"
rm -rf zip/$version
mkdir -p zip/$version
mkdir -p zip/$version/system/lib/modules

# Find all modules that were just built and copy them into the working directory
find -name '*.ko' -exec cp -av {} $pwd/zip/$version/system/lib/modules/ \;
mv mkboot/boot.img zip/$version
cp -R zip/META-INF-l710-tw zip/$version
cd zip/$version
mv META-INF-l710-tw META-INF
zip -r ../tmp.zip ./
cd ..
java -classpath "$loc"testsign.jar testsign "tmp.zip" "$version"-"$date"-signed.zip
rm tmp.zip
mv *.zip ../out
echo "Popped kernel available in the out directory"
echo "Build log is avalable in ~/logs"
echo "Cleaning kernel directory"
# Clean up kernel tree
cd $pwd
rm -rf mkboot 
<<<<<<< HEAD
rm -rf zip
=======
# rm -rf zip
>>>>>>> 512857903638d37956fd40a24b4bb4fccf85ae82
echo "Done"

geany ~/logs/$version.txt || exit 1
