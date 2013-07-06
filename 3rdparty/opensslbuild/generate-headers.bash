#!/bin/bash
# Copyright (c) 2013 The libmumble Developers
# The use of this source code is goverened by a BSD-style
# license that can be found in the LICENSE-file.

# This script creates a hierarchy of header files that mimics
# the standard OpenSSL include directory from OpenSSL tarballs.
#
# Our bundled OpenSSL is a git submodule, and does not include
# the usual header tree, so we have to provide it ourselves in
# opensslbuild.

trap exit SIGINT SIGTERM

cd ../openssl

openssl_ver=$(git describe)
openssl_rev=$(git rev-parse --short HEAD)

git clean -dfx
git reset --hard

./Configure linux-elf
cd ../opensslbuild

rm -rf include/openssl
mkdir -p include/openssl

for fn in $(ls ../openssl/include/openssl); do
	dst=$(readlink ../openssl/include/openssl/${fn})
	cat > include/openssl/${fn} <<EOF
// This file was generated by generate-headers.bash
// on $(date +%Y-%m-%d\ %H:%M:%S%z) using $(uname -sr)
// for OpenSSL version ${openssl_ver} (${openssl_rev})

#include "../../openssl/include/openssl/${dst}"
EOF
done

cat > include/openssl/opensslconf.h <<EOF
// This file was generated by generate-headers.bash
// on $(date +%Y-%m-%d\ %H:%M:%S%z) using $(uname -sr)
// for OpenSSL version ${openssl_ver} (${openssl_rev})

#if LIBMUMBLE_OPENSSLCONF_X86 == 1
# include "../../opensslconf-x86.h"
#elif LIBMUMBLE_OPENSSLCONF_X86_64 == 1
# include "../../opensslconf-x86_64.h"
#elif LIBMUMBLE_OPENSSLCONF_X86_64_LLP == 1
# include "../../opensslconf-x86_64-llp64.h"
#else
# include "../../opensslconf-dist.h"
#endif
EOF

cd ../openssl

git clean -dfx
git reset --hard
