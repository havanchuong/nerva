# Copyright (c) 2018-2024, The Nerva Project
# Copyright (c) 2014-2024, The Monero Project
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of
#    conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list
#    of conditions and the following disclaimer in the documentation and/or other
#    materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors may be
#    used to endorse or promote products derived from this software without specific
#    prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

ANDROID_STANDALONE_TOOLCHAIN_PATH ?= /usr/local/toolchain

dotgit=$(shell ls -d .git/config)
ifneq ($(dotgit), .git/config)
  USE_SINGLE_BUILDDIR=1
endif

subbuilddir:=$(shell echo  `uname | sed -e 's|[:/\\ \(\)]|_|g'`/`git branch | grep '\* ' | cut -f2- -d' '| sed -e 's|[:/\\ \(\)]|_|g'`)
ifeq ($(USE_SINGLE_BUILDDIR),)
  builddir := build/"$(subbuilddir)"
  topdir   := ../../../..
  deldirs  := $(builddir)
else
  builddir := build
  topdir   := ../..
  deldirs  := $(builddir)/debug $(builddir)/release $(builddir)/fuzz
endif

all: release-all

depends:
	cd contrib/depends && $(MAKE) HOST=$(target) && cd ../.. && mkdir -p build/$(target)/release
	cd build/$(target)/release && cmake -DCMAKE_TOOLCHAIN_FILE=$(CURDIR)/contrib/depends/$(target)/share/toolchain.cmake ../../.. && $(MAKE)

cmake-debug:
	mkdir -p $(builddir)/debug
	cd $(builddir)/debug && cmake -D CMAKE_BUILD_TYPE=Debug $(topdir)

debug: cmake-debug
	cd $(builddir)/debug && $(MAKE)

cmake-release:
	mkdir -p $(builddir)/release
	cd $(builddir)/release && cmake -D CMAKE_BUILD_TYPE=Release $(topdir)

release: cmake-release
	cd $(builddir)/release && $(MAKE)

release-all:
	mkdir -p $(builddir)/release
	cd $(builddir)/release && cmake -D CMAKE_BUILD_TYPE=Release $(topdir) && $(MAKE)

release-noaes:
	mkdir -p $(builddir)/release
	cd $(builddir)/release && cmake -D NO_AES=ON -D CMAKE_BUILD_TYPE=Release $(topdir) && $(MAKE)

release-static:
	mkdir -p $(builddir)/release
	cd $(builddir)/release && cmake -D STATIC=ON -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release $(topdir) && $(MAKE)

# Targets for specific prebuilt builds which will be advertised for updates by their build tag

release-static-linux-armv6:
	mkdir -p $(builddir)/release
	cd $(builddir)/release && cmake -D ARCH="armv6zk" -D STATIC=ON -D BUILD_64=OFF -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="linux-armv6" $(topdir) && $(MAKE)

release-static-linux-armv7:
	mkdir -p $(builddir)/release
	cd $(builddir)/release && cmake -D ARCH="armv7-a" -D STATIC=ON -D BUILD_64=OFF -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="linux-armv7" $(topdir) && $(MAKE)

release-static-android-armv7:
	mkdir -p $(builddir)/release/translations
	cd $(builddir)/release/translations && cmake ../../../translations && $(MAKE)
	cd $(builddir)/release && CC=arm-linux-androideabi-clang CXX=arm-linux-androideabi-clang++ cmake -D ARCH="armv7-a" -D STATIC=ON -D BUILD_64=OFF -D CMAKE_BUILD_TYPE=Release -D ANDROID=true -D BUILD_TAG="android-armv7" -D CMAKE_SYSTEM_NAME="Android" -D CMAKE_ANDROID_STANDALONE_TOOLCHAIN="${ANDROID_STANDALONE_TOOLCHAIN_PATH}" -D CMAKE_ANDROID_ARM_MODE=ON -D CMAKE_ANDROID_ARCH_ABI="armeabi-v7a" ../.. && $(MAKE)

release-static-android-armv8:
	mkdir -p $(builddir)/release/translations
	cd $(builddir)/release/translations && cmake ../../../translations && $(MAKE)
	cd $(builddir)/release && CC=aarch64-linux-android-clang CXX=aarch64-linux-android-clang++ cmake -D ARCH="armv8-a" -D STATIC=ON -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D ANDROID=true -D BUILD_TAG="android-armv8" -D CMAKE_SYSTEM_NAME="Android" -D CMAKE_ANDROID_STANDALONE_TOOLCHAIN="${ANDROID_STANDALONE_TOOLCHAIN_PATH}" -D CMAKE_ANDROID_ARCH_ABI="arm64-v8a" ../.. && $(MAKE)

release-static-linux-armv8:
	mkdir -p $(builddir)/release
	cd $(builddir)/release && cmake -D ARCH="armv8-a" NO_AES=ON -D STATIC=ON -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="linux-armv8" $(topdir) && $(MAKE)

release-static-linux-x86_64:
	mkdir -p $(builddir)/release
	cd $(builddir)/release && cmake -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="linux-x64" $(topdir) && $(MAKE)

release-static-freebsd-x86_64:
	mkdir -p $(builddir)/release
	cd $(builddir)/release && cmake -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="freebsd-x64" $(topdir) && $(MAKE)

release-static-mac-x86_64:
	mkdir -p $(builddir)/release
	cd $(builddir)/release && cmake -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="mac-x64" $(topdir) && $(MAKE)

release-static-mac-armv8:
	mkdir -p $(builddir)/release
	cd $(builddir)/release && cmake -D STATIC=ON -D NO_AES=ON -D ARCH="armv8-a" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="mac-armv8" $(topdir) && $(MAKE)

release-static-linux-i686:
	mkdir -p $(builddir)/release
	cd $(builddir)/release && cmake -D STATIC=ON -D ARCH="i686" -D BUILD_64=OFF -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="linux-x86" $(topdir) && $(MAKE)

release-static-win64:
	mkdir -p $(builddir)/release
	cd $(builddir)/release && cmake -G "MSYS Makefiles" -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="win-x64" -D CMAKE_TOOLCHAIN_FILE=$(topdir)/cmake/64-bit-toolchain.cmake -D MSYS2_FOLDER=$(shell cd ${MINGW_PREFIX}/.. && pwd -W) $(topdir) && $(MAKE)

release-static-win32:
	mkdir -p $(builddir)/release
	cd $(builddir)/release && cmake -G "MSYS Makefiles" -D STATIC=ON -D ARCH="i686" -D BUILD_64=OFF -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="win-x32" -D CMAKE_TOOLCHAIN_FILE=$(topdir)/cmake/32-bit-toolchain.cmake -D MSYS2_FOLDER=$(shell cd ${MINGW_PREFIX}/.. && pwd -W) $(topdir) && $(MAKE)

clean:
	@echo "WARNING: Back-up your wallet if it exists within ./"$(deldirs)"!" ; \
    read -r -p "This will destroy the build directory, continue (y/N)?: " CONTINUE; \
	[ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	rm -rf $(deldirs)

clean-all:
	@echo "WARNING: Back-up your wallet if it exists within ./build!" ; \
	read -r -p "This will destroy all build directories, continue (y/N)?: " CONTINUE; \
	[ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	rm -rf ./build

tags:
	ctags -R --sort=1 --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ src contrib

.PHONY: all cmake-debug debug cmake-release release release-all clean tags
