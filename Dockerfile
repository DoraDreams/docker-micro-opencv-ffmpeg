# vim:set ft=dockerfile:

FROM docker.io/python:3-alpine
MAINTAINER Chao Hu <chao@ngs.tech>

RUN \
	echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \

    # Install libraries
	apk update && \
	apk add \
	tzdata \
	libass \
	libstdc++ \
	libpng \
	libjpeg \
	xvidcore \
	x264-libs \
	x265 \
	libvpx \
	libvorbis \
	opus \
	lame \
	fdk-aac \
    	curl \
	libtool \
	freetype && \

	# Install build tools
	apk add --virtual build-deps \
	fdk-aac-dev \
	freetype-dev \
	x264-dev \
	x265-dev \
	yasm \
	yasm-dev \
	libogg-dev \
	libvorbis-dev \
	opus-dev \
	libvpx-dev \
	lame-dev \
	xvidcore-dev \
	libass-dev \
	openssl-dev \
	musl-dev \
	make \
	cmake \
	gcc \
	g++ \
	build-base \
	libjpeg-turbo-dev \
	libpng-dev \
	libjasper \
	clang-dev \
	clang \
	linux-headers \
    	automake \
	autoconf \
	git && \

	export SRC=/usr \
	export FFMPEG_VERSION=3.3.2 \

	DIR=$(mktemp -d) && cd ${DIR} && \
	curl -Os http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
	tar xzvf ffmpeg-${FFMPEG_VERSION}.tar.gz && \
	cd ffmpeg-${FFMPEG_VERSION} && \
	./configure --prefix="${SRC}" --extra-cflags="-I${SRC}/include" --extra-ldflags="-L${SRC}/lib" --bindir="${SRC}/bin" \
	--extra-libs=-ldl --enable-version3 --enable-libmp3lame --enable-pthreads --enable-libx264 --enable-libxvid --enable-gpl \
	--enable-postproc --enable-nonfree --enable-avresample --enable-libfdk-aac --disable-debug --enable-small --enable-openssl \
	--enable-libx265 --enable-libopus --enable-libvorbis --enable-libvpx --enable-libfreetype --enable-libass \
	--enable-shared --enable-pic && \
	make -j4 && \
	make install && \
	make distclean && \
	hash -r && \
	cd /tmp && \
	rm -rf ${DIR} && \

	# Fix numpy
	ln -s /usr/include/locale.h /usr/include/xlocale.h && \
	pip install --no-cache-dir \
	Cython==0.25.2 \
	numpy==1.13.1 \
	Pillow==4.2.1 \
	av==0.3.3 && \

	# OpenCV
	export OPENCV_VERSION=3.2.0 \

	export CC=/usr/bin/clang \
	export CXX=/usr/bin/clang++ && \

	DIR=$(mktemp -d) && cd ${DIR} && \
	curl -sSL -Os https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.tar.gz && \
	tar xzvf ${OPENCV_VERSION}.tar.gz && \
	cd opencv-${OPENCV_VERSION} && \
	mkdir build && \
	cd build && \
	cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D INSTALL_C_EXAMPLES=OFF \
	-D INSTALL_PYTHON_EXAMPLES=OFF \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D BUILD_EXAMPLES=OFF .. && \
	make -j4 && \
	make install && \
	cp ${DIR}/opencv-${OPENCV_VERSION}/build/lib/python3/cv2.cpython-36m-x86_64-linux-gnu.so /usr/local/lib/python3.6/cv2.so && \
	cd /tmp && \
	rm -rf ${DIR} && \

    	# Curl library
   	DIR=$(mktemp -d) && cd ${DIR} && \
	git clone https://github.com/curl/curl.git && \
	cd curl && \
	./buildconf && \
	./configure --prefix=/usr --with-ssl --enable-ipv6 --enable-unix-sockets --without-libidn --disable-static --disable-ldap --with-pic  && \
	make && \
	make install && \
	rm -rf ${DIR} && \

    	# RESTClient cpp library
    	DIR=$(mktemp -d) && cd ${DIR} && \
	git clone https://github.com/mrtazz/restclient-cpp.git && \
	cd restclient-cpp && \
	sh ./autogen.sh && \
	./configure && \
	make && \
	make install && \
	rm -rf ${DIR} && \

	# Install boost library
	DIR=$(mktemp -d) && cd ${DIR} && \
	curl -sSL -Os https://nchc.dl.sourceforge.net/project/boost/boost/1.63.0/boost_1_63_0.tar.bz2 && \
	bzip2 -d boost_1_63_0.tar.bz2 && \
	tar -xvf boost_1_63_0.tar && \
	cd boost_1_63_0 && \
	sh ./bootstrap.sh && \
	./b2 install && \
	rm -rf ${DIR} && \

	# Cleaning up
	apk del build-deps && \
	rm -rf /var/cache/apk/*

