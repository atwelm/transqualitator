#!/usr/bin/env bash

set -e

mkdir ~/ffmpeg_sources

sudo apt-get update -qq && sudo apt-get -y install \
	autoconf \
	automake \
	build-essential \
	cmake \
	git-core \
	libass-dev \
	libfreetype6-dev \
	libgnutls28-dev \
	libmp3lame-dev \
	libsdl2-dev \
	libtool \
	libva-dev \
	libvdpau-dev \
	libvorbis-dev \
	libxcb1-dev \
	libxcb-shm0-dev \
	libxcb-xfixes0-dev \
	meson \
	ninja-build \
	pkg-config \
	texinfo \
	wget \
	yasm \
	zlib1g-dev

sudo apt-get install libx264-dev libx265-dev libfdk-aac-dev

# Install vmaf for quality comparison
if [[ ! -f "${HOME}/ffmpeg_build/bin/vmaf" ]];then
	cd ~/ffmpeg_sources && \
		wget https://github.com/Netflix/vmaf/archive/v2.1.1.tar.gz && \
		tar xvf v2.1.1.tar.gz && \
		mkdir -p vmaf-2.1.1/libvmaf/build &&\
		cd vmaf-2.1.1/libvmaf/build && \
		meson setup -Denable_tests=false -Denable_docs=false --buildtype=release --default-library=static .. --prefix "$HOME/ffmpeg_build" --bindir="$HOME/ffmpeg_build/bin" --libdir="$HOME/ffmpeg_build/lib" && \
		ninja && \
		ninja install
fi


cd ~/ffmpeg_sources && \
	wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
	tar xjvf ffmpeg-snapshot.tar.bz2 && \
	cd ffmpeg &&
	PATH="$HOME/bin:$HOME/ffmpeg_build/bin:$PATH" PKG_CONFIG_PATH="$HOME/.local/opt/ffmpeg/lib/pkgconfig" ./configure   --prefix="$HOME/ffmpeg_build"   --pkg-config-flags="--static"   --extra-cflags="-I$HOME/ffmpeg_build/include"   --extra-ldflags="-L$HOME/ffmpeg_build/lib"   --extra-libs="-lpthread -lm"   --ld="g++"   --bindir="$HOME/bin"   --enable-gpl   --enable-gnutls   --enable-libaom   --enable-libass   --enable-libfdk-aac   --enable-libfreetype   --enable-libmp3lame   --enable-libopus   --enable-libsvtav1   --enable-libdav1d   --enable-libvorbis   --enable-libvpx   --enable-libx264   --enable-libx265   --enable-nonfree --enable-libvmaf  --extra-libs="-lpthread" &&
	PATH="$HOME/bin:$PATH" make -j8


