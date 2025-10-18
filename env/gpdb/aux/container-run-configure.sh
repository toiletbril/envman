#!/bin/bash

# Taken from ABI tests.
# Will be placed inside of the container.

DBG_EXT='--enable-debug-extensions --enable-debug --enable-cassert'
CFLAGS='-O0 -g3 -Wno-maybe-uninitialized -fno-omit-frame-pointer -fuse-ld=mold'

export CC='gcc -m64'
export CFLAGS="$CFLAGS"
export CXXFLAGS="$CFLAGS"
export LDFLAGS='-Wl,--enable-new-dtags -Wl,--export-dynamic'

V="$(cut -b 1 < VERSION)"

case $V in
'6')
./configure --disable-gpperfmon --with-gssapi --enable-mapreduce \
            --enable-orafce --enable-ic-proxy --enable-orca --with-libxml \
            --with-pythonsrc-ext --with-uuid=e2fs --with-pgport=5432 \
            --enable-tap-tests --with-perl --with-python --with-openssl \
            --with-pam --with-ldap --with-includes="" --with-libraries="" \
            --disable-rpath $DBG_EXT --prefix='/usr/local/greenplum-db-devel' \
            --mandir=/usr/local/greenplum-db-devel/man;;
'7')
./configure --with-gssapi --enable-orafce --enable-ic-proxy --enable-orca \
            --enable-gpcloud --with-libxml --with-openssl --with-pam \
            --with-ldap --with-uuid=e2fs --with-llvm --with-pgport=5432 \
            $DBG_EXT --with-gssapi --enable-depend --with-perl --with-python \
            --prefix='/usr/local/greenplum-db-devel' PYTHON=python3 \
            --with-includes='/home/gpadmin/gpdb_src/gpAux/ext/ubuntu22.04_x86_64/include /home/gpadmin/gpdb_src/gpAux/ext/ubuntu22.04_x86_64/include/libxml2' \
            --with-libraries='/home/gpadmin/gpdb_src/gpAux/ext/ubuntu22.04_x86_64/lib' \
            --disable-rpath LDFLAGS='-Wl,--enable-new-dtags -Wl,-rpath,$/../lib';;
*)
echo "ERROR: invalid GPDB version :("
exit 1;;
esac
