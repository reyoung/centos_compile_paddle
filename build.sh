#!/bin/bash
git clone --depth 1 https://github.com/PaddlePaddle/Paddle.git /paddle
mkdir -p /paddle/build
mkdir -p /paddle_dist
cd /paddle/build
export CPLUS_INCLUDE_PATH=/usr/include/:$CPLUS_INCLUDE_PATH
cmake .. -DWITH_GPU=OFF -DPYTHON_EXECUTABLE=/opt/python/bin/python \
	-DPYTHON_LIBRARY=/opt/python/lib/libpython2.7.a\
	-DWITH_MKLDNN=OFF -DCMAKE_EXE_LINKER_FLAGS='-lutil'
make -j `nproc` 2>&1 | tee -a /paddle_dist/build.log
make DESTDIR=/paddle_dist -j `nproc` install 2>&1 | tee -a /paddle_dist/build.log
cp -r /opt/python /paddle_dist/
cd /paddle_dist
tar cJvf paddle.tar.xz usr/
tar cJvf python.tar.xz python
