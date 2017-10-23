#!/bin/bash

# Setting up build env
sudo yum update -y
sudo yum install -y git cmake gcc-c++ gcc python36-devel chrpath
mkdir -p lambda-package/cv2 build/numpy

# Build numpy
python36 -m pip install --install-option="--prefix=$PWD/build/numpy" numpy
cp -rf build/numpy/lib64/python2.7/site-packages/numpy lambda-package

# Build OpenCV 3.2
(
	NUMPY=$PWD/lambda-package/numpy/core/include
	cd build
	git clone https://github.com/opencv/opencv.git
	cd opencv 
	git checkout 3.3.0 
	cd ..
	git clone https://github.com/opencv/opencv_contrib.git
	cd opencv_contrib
	git checkout 3.3.0
	cd ..
	cd opencv
	mkdir build
	cd build
	cmake										\
		 -D CMAKE_BUILD_TYPE=RELEASE				\
		 -D WITH_TBB=ON							\
		 -D WITH_IPP=ON							\
		 -D WITH_V4L=ON							\
		 -D ENABLE_AVX=ON						\
		 -D ENABLE_SSSE3=ON						\
		 -D ENABLE_SSE41=ON						\
		 -D ENABLE_SSE42=ON						\
		 -D ENABLE_POPCNT=ON						\
		 -D ENABLE_FAST_MATH=ON					\
		 -D BUILD_EXAMPLES=OFF					\
		 -D BUILD_TESTS=OFF						\
		 -D BUILD_PERF_TESTS=OFF				\
		 -D PYTHON3_NUMPY_INCLUDE_DIRS="$NUMPY"	\
		 ..
	make -j 'cat /proc/cpuinfo | grep MHz | wc -l'
)

cd /tmp
cp build/opencv/build/lib/cv2.so lambda-package/cv2/__init__.so
cp -L build/opencv/build//lib/*.so.3.3 lambda-package/cv2
strip --strip-all lambda-package/cv2/*
chrpath -r '$ORIGIN' lambda-package/cv2/__init__.so
touch lambda-package/cv2/__init__.py

# Copy template function and zip package
cp template.py lambda-package/lambda_function.py
cd lambda-package
zip -r ../lambda-package.zip *
