#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
rm -rf *
../configure \
--enable-static \
--enable-shared \
--prefix=${SOFT_DIR}
make install
echo "Creating the modules file directory ${LIBRARIES}"
mkdir -p ${LIBRARIES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/JPEG-deploy"
setenv JPEG_VERSION       $VERSION
setenv JPEG_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(JPEG_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(JPEG_DIR)/include
prepend-path CFLAGS            "-I$::env(JPEG_DIR)/include"
prepend-path LDFLAGS           "-L$::env(JPEG_DIR)/lib"
MODULE_FILE
) > ${LIBRARIES}/${NAME}/${VERSION}


module  avail ${NAME}
module add ${NAME}/${VERSION}
