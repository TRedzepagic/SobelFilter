#!/bin/bash

echo "Compiling SobelFilter"
g++ -c SobelFilter.cpp -l OpenCL -I ./common/OpenCL/include -I ./common/FreeImage/include -o SobelFilter.a

echo "Compiling EdgeDetector"
g++ RunSobel.cpp SobelFilter.a ./common/FreeImage/lib/linux/x86_64/libfreeimage.a -l OpenCL -I ./common/OpenCL/include -o sobel

./sobel ./images/me.jpg prewitt
./sobel ./images/me.jpg sobel
./sobel ./images/me.jpg scharr
./sobel ./images/me.jpg roberts

sxiv sobel_me.bmp
sxiv prewitt_me.bmp
sxiv scharr_me.bmp
sxiv roberts_me.bmp
